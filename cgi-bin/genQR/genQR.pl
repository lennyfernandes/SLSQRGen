#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
use PDF::API2;
use GD::Barcode::QRcode;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use Template;
print "Content-type: text/html\n\n";

my $localtime = localtime();
my @arr_local_date_time = split(/\s/, uc($localtime));

my $SITE_NAME = "http://sls.com";

my $dbh = &dbConnect;
my %EMB = &fetchCGIVars;

our $sub = !exists $EMB{action} || !defined $EMB{action} ? "invalidAccess" : $EMB{action};
&callMain($sub, 0);

$dbh->disconnect();
exit(0);

sub invalidAccess {
	print qq(<h1><font color="#FF0000">INVALID ACCESS !!!</h1>);
}# end of : sub invalidAccess {

sub dbConnect {
	return DBI->connect("DBI:mysql:sls",'quantumd','admlqq');
}# end of : sub dbConnect {

sub callMain {
    my ($subActionCall, $status) = @_;
    my $sub = \&{$subActionCall};
    !defined $status || $status == 1 ? &displayLoginPage : &{$sub};
}# end of : sub callMain {

sub fetchCGIVars {
    my $query = new CGI; # this will import the form values
    return $query->Vars(); # this will "export" the form values
}# end of : sub fetchCGIVars {

sub loadGenQR {
	if(!exists $EMB{product_batch_month} && !exists $EMB{product_batch_year}) {
		($EMB{product_batch_month},$EMB{product_batch_year}) = ($arr_local_date_time[1],$arr_local_date_time[5]);
	}
	my $MESSAGE_DISPLAY = exists $EMB{MESSAGE_DISPLAY} && $EMB{MESSAGE_DISPLAY} ne "" ? $EMB{MESSAGE_DISPLAY} : "";
	my $loadUniqCodes = &loadUniqCodes;
	my %createQR = (	MESSAGE_DISPLAY => $MESSAGE_DISPLAY,
					 	CURRENT_MONTH => $EMB{product_batch_month}, 
						CURRENT_YEAR => $EMB{product_batch_year},
						product_name => $EMB{product_name},
						product_code => $EMB{product_code},
						product_batch => $EMB{product_batch},
						loadUniqCodes => $loadUniqCodes
					);
	my $tt_1 = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1 } ) or die "$Template::ERROR\n";
    my $CONTAINER_DATA;
	$tt_1->process('createQR.tt', \%createQR, \$CONTAINER_DATA) or die $tt_1->error(), "\n";    
	
	my %CONTAINER_DATA = ( CONTAINER_DATA => $CONTAINER_DATA );
    my $tt = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1, } ) or die "$Template::ERROR\n";
	$tt->process('master.tt', \%CONTAINER_DATA) or die $tt->error(), "\n";
}# end of : sub loadGenQR {

sub check_qrcode_entry {
	my $check_query = "select pdfName from qrcodes WHERE product_name='$EMB{product_name}' AND product_code='$EMB{product_code}' AND product_batch='$EMB{product_batch}' AND product_batch_MY='$EMB{product_batch_MY}'";
	return $dbh->selectrow_array($check_query);
}# end of : sub check_qrcode_entry {

sub insQRCode {
	my $ins_query = "insert into qrcodes set product_name=?, product_code=?, product_batch=?, product_batch_MY=?, pdfName=?, createdOn=now()";
	my $ins_sth = $dbh->prepare($ins_query);
	my $sth_msg = $ins_sth->execute($EMB{product_name}, $EMB{product_code}, $EMB{product_batch}, $EMB{product_batch_MY},$EMB{FILE_NAME});
	my $ins_rows = $ins_sth->rows();
	$ins_sth->finish();
	return defined $ins_rows && $ins_rows =~ /^1$/ ? 1 : 0; 
}# end of : sub insQRCode {

sub create_unique_product_code {
	my $ins_query = "insert into unique_product_codes set product_name='$EMB{product_name}', product_code='$EMB{product_code}', createdOn=now()";
	$dbh->do($ins_query);
}# end of : sub create_unique_product_code {

sub check_unique_product_codes {
	my $check_query = "select * from unique_product_codes WHERE product_name='$EMB{product_name}' AND product_code='$EMB{product_code}'";
	my $data = $dbh->selectrow_array($check_query);	
	return if(defined $data && $data ne "");
	&create_unique_product_code;
}# end of : sub create_unique_product_codes {

sub loadExistingQR {
	my $PDF_FILE_PATH_NAME = shift;
	my $MESSAGE_DISPLAY = qq(
		<h3><font color="#FF0000">WARNING !!! QR-CODE ALREADY GENERATED/PRINTED/AVAILABLE !!!</font></h3>
		<h4>
			<br><br>$EMB{product_name}
			<br><br>$EMB{product_code}/$EMB{product_batch}
			<br><br>$EMB{product_batch_month}/$EMB{product_batch_year}
		</h4>
	);
	my %createQR = ( MESSAGE_DISPLAY => $MESSAGE_DISPLAY, PDF_FILE_PATH_NAME => $PDF_FILE_PATH_NAME );
	my $tt_1 = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1 } ) or die "$Template::ERROR\n";
    my $CONTAINER_DATA;
	$tt_1->process('reprintQR.tt', \%createQR, \$CONTAINER_DATA) or die $tt_1->error(), "\n";    
	
	my %CONTAINER_DATA = ( CONTAINER_DATA => $CONTAINER_DATA );
    my $tt = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1, } ) or die "$Template::ERROR\n";
	$tt->process('master.tt', \%CONTAINER_DATA) or die $tt->error(), "\n";
}# end of : sub loadExistingQR {

sub genQR {
	my $PRODUCT_NAME = $EMB{product_name};
	my $PRODUCT_CODE = $EMB{product_code};
	my $PRODUCT_BATCH = sprintf("%04d", $EMB{product_batch});
	my $PRODUCT_BATCH_MONTH = $EMB{product_batch_month};
	my $PRODUCT_BATCH_YEAR = $EMB{product_batch_year};
	$EMB{product_batch_MY} = qq($EMB{product_batch_month}/$EMB{product_batch_year});
	
	$EMB{FILE_NAME} = $PRODUCT_BATCH_MONTH."_".$PRODUCT_BATCH_YEAR."_".$PRODUCT_BATCH."_".$$;
	
	# first check if the entry is already AVAILABLE ...
	my $pdfName = &check_qrcode_entry;
	return &loadExistingQR($pdfName) if(defined $pdfName && $pdfName); # RETURN if ENTRY IS AVAILABLE...

	&check_unique_product_codes;

	my $insQRCodeStatus = &insQRCode;
	
	if(!$insQRCodeStatus) { # FAILURE STORING QR CODE ENTRY...
		$EMB{MESSAGE_DISPLAY} = qq(<h4><font color="#ff0000">QR-Code Generation - FAILED !!! Duplicate Found</font></h4>);
		return &loadGenQR ;
	}	
	
    my $pdf = PDF::API2->new();
    my $page = $pdf->page();
    
    my $pdf_Width = 4; # inches...
    my $pdf_Height = 3; # inches... 
    $page->mediabox($pdf_Width * 72, $pdf_Height * 72);
    
    my $gfx = $page->gfx();
    my $text = $page->text();
    my $times = $pdf->corefont('Times-Roman');

	my $QR_CODE_IMAGE = $ENV{DOCUMENT_ROOT}."/qrcodes/$EMB{FILE_NAME}.png";
	
	my $QR_CODE_TEXT = qq($PRODUCT_NAME; $PRODUCT_CODE/$PRODUCT_BATCH; $PRODUCT_BATCH_MONTH/$PRODUCT_BATCH_YEAR);
	
	open my $OUT, '>', $QR_CODE_IMAGE;
	binmode($OUT);
	my $gd = GD::Barcode::QRcode->new(
		$QR_CODE_TEXT,
		{ Ecc => 'M', Version=>4, ModuleSize => 8},
	);
	print $OUT $gd->plot->png;
	close $OUT;
	
	# first store the QR-Code PNG Image...	
	my $img_1 = $pdf->image_png($QR_CODE_IMAGE);
	my ($img_1_width, $img_1_Height) = ($img_1->width,$img_1->height);

	$gfx->image($img_1,60,55,0.5);

	$text->translate(50,50);
	$text->font($times,13);
	$text->text($PRODUCT_NAME);

	$text->translate(50,30);
	$text->font($times,13);
	$text->text($PRODUCT_CODE."/".$PRODUCT_BATCH);

	$text->translate(50,10);
	$text->font($times,13);
	$text->text($PRODUCT_BATCH_MONTH."/".$PRODUCT_BATCH_YEAR);

    # SAVE PDF
    my $PDF_FILE_PATH_NAME = "/bcpdf/$EMB{FILE_NAME}.pdf";
    $pdf->saveas($ENV{DOCUMENT_ROOT}.$PDF_FILE_PATH_NAME);
	$pdf->end();
    
    my $CONTENT_PRINT_LINK = "";
    my $barcodeGenMsg = qq(<font color="#ff0000">QR-Code Generation - FAILED !!!</font>);
    if(-e $ENV{DOCUMENT_ROOT}.$PDF_FILE_PATH_NAME) {
        $barcodeGenMsg = qq(
			<br><br>
			<h3>
				<font color="#2960DE">QR-Code Generation - SUCCESS !!!</font>
				<br><br>
				<a href="#" onclick="myPopup('$PDF_FILE_PATH_NAME','Barcode',410,440);">Print QR-Code</a>
			</h3>
		);
    }    
    my %data = ( CONTAINER_DATA => $barcodeGenMsg );
    my $tt = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1, } ) or die "$Template::ERROR\n";
    my $CONTENT_DATA;
    $tt->process('master.tt', \%data, \$CONTENT_DATA) or die $tt->error(), "\n";
    print $CONTENT_DATA;
}# end of : sub genQR {

sub loadUniqCodes {
	my $fetch_query = "select srid,product_name,product_code from unique_product_codes ORDER BY product_name ASC";
    my $dataRef = $dbh->selectall_arrayref($fetch_query);
    my $dataRefLen = @{$dataRef};
    my @DATA = ();
	return \@DATA if(!$dataRefLen);
    my ($srid,$product_name,$product_code,);
    for(my $i=0; $i<$dataRefLen; $i++) {
        ($srid,$product_name,$product_code) = @{$dataRef->[$i]};
        push(@DATA, { srno => $i+1, srid => $srid, product_name => $product_name, product_code => $product_code });
    }
    return \@DATA;
}# end of : sub loadUniqCodes {

sub delUniqCode {
	my $delQuery = "delete from unique_product_codes WHERE srid='$EMB{srid}'";
	$dbh->do($delQuery);
	&loadGenQR;
}# end of : sub delUniqCode {
