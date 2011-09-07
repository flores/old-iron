#!/usr/bin/perl

# this here script was written by wet@petalphile.com
# for fellow aquatic plant nerds.  As long as you keep 
# this notice, you can do what you want with it.  But 
# if you have ideas or make it better, please let me 
# know.  I'll probably want to help and like good ideas
#
# :) - c


use CGI::Form;

$q = new CGI::Form;
print $q->header();

print $q->start_html(-title=>'Fe target or by dose planted aquarium calculator');
print "<center>\n";




if ($q->cgi->var('REQUEST_METHOD') eq 'GET') {

	undef($target);
	undef($dose);
	undef($compound);
	undef($tank);
	undef($dose_type);
	&printForm($q,$val);


 } else {

	my $target=$q->param('target');
        my $dose=$q->param('dose');
        my $dose_type=$q->param('dose_type');
        my $compound=$q->param('compound');
        my $tank=$q->param('tank');
	my $tank_units=$q->param('tank_units');

# check for bogus entries.
	$err=0;
	if ( ($dose && $target) )
	{	
		print "Enter either target or dose. Do not enter both.<br />\n";	
		$err=1;
	}
	if ( !$dose && $err==0 && ( $target!~/^\.?[\d]+\.?\d*$/ || $target=~/.*\..*\./ || $target=~/[A-Z]|[a-z]/ )	)
	{
		print "Your target Fe ppm must be a real number.<br />\n";
		$err=1;
	}
	if ( !$target && $err==0 && ( ( $dose!~/^\.?[\d]+\.?\d*$/ || $dose=~/.*\..*\./  ) && $dose_type=~/mg/ )	)
	{
		print "Your dose must be a real number.<br />\n";
		$err=1;
	}
	if ($dose=~/(\d+)\s*?\/\s*?(\d+)/)
	{
		my $num=$1;
		my $den=$2;
#		print "tsp is $num over $den";
		$dose = ( $num / $den );
#		print "dose is $dose";
	}

	if ( ($tank!~/^\.?[\d]+\.?\d*$/) || ($tank=~/.*\..*\./) || ($tank=~/[A-Z]|[a-z]/) )	
	{
		print "Your tank gallons must be a real number.<br />\n";
		$err=1;
	}
	
	if (!$compound)
	{
		print "Please choose one of the compounds listed.<br />\n";
		$err=1;
	}
	
	if ($dose_type=~/tsp/ && $compound=~/Rexolin/)
	{
		print "I don\'t have density for $compound.  Please <a href='http://www.aquaticplantcentral.com/forumapc/fertilizing/68558-dry-sources-fe-calculator.html' target='_blank'>help</a>!<br />\n";
		$err=1;
	}


	$op=$q->param('Action');
	if ($op eq "Gimmie!" && $err==0) 
	{
		if ($tank_units=~/gal/)
		{
			$vol=$tank*3.78541178;
		}
		else
		{
			$vol=$tank;
		}
		#concentrations
		if ($compound=~/10/)
		{
			$con=0.1;
			$tsp_con=4290;
		}
		elsif ($compound=~/Rexolin/)
		{
			$con=0.06;
			$con_mn=0.024;
			$con_cu=0.0025;
		}
		elsif ($compound=~/EDTA \(12/)
		{
			$con=0.125;
			$tsp_con=5100;
		}
		elsif ($compound=~/Gluconate/)
		{
			$con=0.1246;
			$tsp_con=2440;
		}
		elsif ($compound=~/Super/)
		{
			$con=0.06;
			$tsp_con=2420;
		}
		elsif ($compound=~/Plantex/)
		{
			$con=0.0653;
			$con_mn=0.0187;
			$con_cu=0.009;
			$tsp_con=4300;
		}
		elsif ($compound=~/Micro/)
		{
			$con=0.04;
			$con_mn=0.04;
			$con_cu=0.015;
			$tsp_con=3720;
		}

		if ($dose_type=~/tsp/)
		{
#			print "converted dose is $dose mg";
			$dose= ($dose * $tsp_con);
#			print "converted dose is $dose mg";
		}			

		if ($dose)
		{
			$dose_calc=$dose;
			$target_calc=($dose*$con)/$vol;
			$target_calc=sprintf("%.4f", $target_calc);
#			$target_calc=~/(.*\.\d\d).+$/;
#			$target_calc=$1;
		}
		elsif ($target)
		{
			$target_calc=$target;
			$dose_calc=($target*$vol/$con);
			$dose_calc=sprintf("%.3f", $dose_calc);
#			$dose_calc=~/(.*\.\d\d).+$/;
#			$dose_calc=$1;
		}
		
		print "<br \><b>$dose_calc</b> mg of $compound<br />into $tank $tank_units gives <b>$target_calc</b> ppm Fe.<br \>\n";

		if ($con_mn && $con_cu)
		{
			$target_mn=($dose_calc*$con_mn)/$vol;
			$target_cu=($dose_calc*$con_cu)/$vol;
			$target_mn=sprintf("%.3f", $target_mn);
			$target_cu=sprintf("%.3f", $target_cu);
			print "... and $target_mn ppm of Manganese and $target_cu ppm of Copper, along with other traces.<br \>\n";
		}

		print "<br />";
	}
	    
	else
	{
		print "please fix the above and reGimmie.<br /><br />\n";
		$err=0;
	}

	$q->param('hiddenValue',$val);

	&printForm($q);

	print $q->endform;	
	print $q->end_html;
}




 sub printForm {

    my($q,$val)=@_;

    print $q->start_multipart_form();

    print "\n<center>\n";
#    print "<TABLE>\n<TR>\n<TD COLSPAN=3>\n";

    print "My target is ";

    print $q->textfield( -name=>'target',-size=>4,-maxlength=>4 );

    print " ppm Fe<br />";
#    print "</TD>\n</TR>\n<TR>\n<TD COLSPAN=1>\n";
    print "or<br />\n";

#    print "</TD>\n</TR>\n<TR>\n<TD COLSPAN=3>\n";
    print "My dose is ";

    print $q->textfield( -name=>'dose',-size=>9,-maxlength=>7 );
    print $q->radio_group( -name=>'dose_type', values=>['mg', 'tsp'], -default=>'mg' );
    print "<br />\n";
    
 #   print "</TD>\n</TR>\n<TR>\n<TD COLSPAN=1>\n";
    print "from<br />\n";
 #   print "</TD>\n</TR>\n<TR><TD COLSPAN=3>\n";
    print $q->radio_group( -name=>'compound', values=>['Plantex CSM+B (6.53%)', 'Miller MicroPlex (4%)', 'Rexolin APN (6%)', 'Fe Gluconate (12.46%)'] );
    print "<br />\n";
    print $q->radio_group( -name=>'compound', values=>['DTPA Fe (10%)', 'EDTA Fe (12.5%)', 'EDDHA Fe aka Super Iron (6%)'], -default=>'EDDHA Fe aka Super Iron (6%)' );

#    print "</TD>\n</TR>\n<TR><TD COLSPAN=1>\n";
    print "<br />\nand<br />\n";
#    print "</TD>\n</TR>\n<TR><TD COLSPAN=3>\n";
    print "my tank is ";
    print $q->textfield( -name=>'tank',-size=>4,-maxlength=>4 );
    print $q->radio_group( -name=>'tank_units', values=>['gal','L'], -default=>'gal'); #  " gallons<br /><br />";
    print "<br />\n<br />\n";

    print $q->submit( -name=>'Action',-value=>'Gimmie!' );

#    print "</TD></TR>\n";

#    print "</TABLE>\n";


	print "<br /><br />This calculator is old news but will always be around.<br>Check out <b><a href='http://calc.petalphile.com'>calc.petalphile.com</a></b> for more stuff!\n";
 }




