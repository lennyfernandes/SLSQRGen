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

sub check_qrcode_entry {
	my $check_query = "select pdfName from qrcodes WHERE product_name='$EMB{product_name}' AND product_code='$EMB{product_code}' AND product_batch='$EMB{product_batch}' AND product_batch_MY='$EMB{product_batch_MY}'";
	return $dbh->selectrow_array($check_query);
}# end of : sub check_qrcode_entry {

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

sub viewQRLog {
    my %searchBy = ( 1 => "product_name", 2 => "product_code", 3 => "product_batch", 4 => "product_batch_MY");
    my $fieldName = $searchBy{$EMB{searchBy}};
    my $queryClause = exists $EMB{searchBy} && $EMB{searchBy} ne "" ? qq(WHERE $fieldName LIKE '%$EMB{searchValue}%') : "";
	my $fetch_query = "select product_name,product_code,product_batch,product_batch_MY,createdOn,pdfName from qrcodes $queryClause ORDER BY createdOn DESC";
    my $dataRef = $dbh->selectall_arrayref($fetch_query);
    my $dataRefLen = @{$dataRef};
    my $CONTAINER_DATA = qq(
        <br><br>
        <CENTER>
        <h3>
            <font color="#FF000">SORRY - NO RECORDS FOUND !!!</font>
        </h3>
        </CENTER>
    );
    return &CONTAINER_DATA($CONTAINER_DATA) if(!$dataRefLen);
    $CONTAINER_DATA = "";
    my ($product_name,$product_code,$product_batch,$product_batch_MY,$createdOn,$pdfName);
    my @DATA = ();
    for(my $i=0; $i<$dataRefLen; $i++) {
        ($product_name,$product_code,$product_batch,$product_batch_MY,$createdOn,$pdfName) = @{$dataRef->[$i]};
        push(@DATA, { srid => $i+1, product_name => $product_name, product_code => $product_code, product_batch => $product_batch, product_batch_MY => $product_batch_MY, createdOn => $createdOn, pdfName => $pdfName });
    }
    my %viewQRLog = (DATA => \@DATA);
    my $tt_1 = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1 } ) or die "$Template::ERROR\n";
	$tt_1->process('viewQRLog.tt', \%viewQRLog, \$CONTAINER_DATA) or die $tt_1->error(), "\n";    
    &CONTAINER_DATA($CONTAINER_DATA);
}# end of : sub viewQRLog {

sub CONTAINER_DATA {
    my $CONTAINER_DATA = shift;
    my %CONTAINER_DATA = ( CONTAINER_DATA => $CONTAINER_DATA );
    my $tt = Template->new( { INCLUDE_PATH => $ENV{DOCUMENT_ROOT}, INTERPOLATE  => 1, } ) or die "$Template::ERROR\n";
	$tt->process('master.tt', \%CONTAINER_DATA) or die $tt->error(), "\n";
}# end of : sub CONTAINER_DATA {