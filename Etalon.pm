=head1 

F2T2::Etalon

PDL module for etalon basics

Created: 17/12/2007

=cut

package PDL::F2T2::Etalon;

require Exporter;

@ISA    = qw( Exporter );
@EXPORT = qw( $Pi $mu transmission gap peaklambda finesse reflectance generate_model reflectionfit );

use PDL;
use PDL::NiceSlice;
use PDL::Graphics::PGPLOT;

=pod

$Pi is the value of Pi

=cut

$mu = 1.00028; #index of refraction	      
$Pi = 4.0*atan2(1,1);	      

sub barf { die sprintf("%s in %s() at %s line %d\n",$_[0],(caller(1))[3,1,2]) }

=pod

transmission(): Define the transmission as a function of wavelength (this is just an airy function). Transmission will depend on the reflectivity R, refractive index mu, gap, and off-axis angle, theta, of the incoming ray.

=cut

sub transmission {
    barf 'Usage: transmission(lambda,gap,finesse,[theta])' if scalar(@_)<3;

    my($lambda,$gap,$finesse,$theta) = @_;
    $theta = 0.0 if scalar(@_)==3;
    my $R = reflectance($finesse);
    my $den = 1 + 4.0* $R * (1-$R)**(-2.0) * sin(2.0*$Pi* $mu * $gap * cos($theta) / $lambda)**2; 
    return 1.0 / $den;
}

=pod 

gap(): work out the gap between the plates needed to obtain a peak at a central wavelength of lambda. This depends on the order (m), refractive index (mu), and off-axis angle (theta) of the incoming ray. Units of gap and lambda are the same.

=cut

sub gap {
    barf 'Usage: gap(lambda,order,[theta])' if scalar(@_)<2;
    my($lambda,$order,$theta) = @_;
    $theta = 0.0 if scalar(@_)==2;
    return $order * $lambda / (2.0 * $mu * cos($theta));
} 

=pod

peaklambda(gap,order): given a gap and order, calculate the location of the peak wavelength. Units of gap and lambda are the same.

=cut

sub peaklambda {
    barf 'Usage: peaklambda(gap,order,[theta])' if scalar(@_)<2;
    my($gap,$order,$theta) = @_;
    $theta = 0.0 if scalar(@_)==2;
    return $gap * 2.0 * $mu * cos($theta) / $order;
}

=pod 

finesse(): depends only on reflectance R

=cut

sub finesse { 
    barf 'Usage: finesse(reflectivity)' if scalar(@_)!=1;
    my $R = $_[0];
    return $Pi * sqrt($R) / (1.0 - $R);
}

=pod

reflectance(): calculate reflectivity of etalon given the finesses

=cut

sub reflectance {
    barf 'Usage: reflectance(finesse)' if scalar(@_)!=1;
    my $finesse = $_[0];
    my $num = $Pi**2 + 2.0 * $finesse**2 - $Pi * sqrt( $Pi**2 + 4.0 * $finesse**2);
    my $den = 2.0 * $finesse**2;
    return $num / $den ; 
}

=pod 

generate_model(): generate a etalon transmission spectrum given lambda, gap and finesse

=cut

sub generate_model {
    barf 'Usage: generate_model(lamba,gap,finesse,[theta])' if scalar(@_)<3;
    my($lambda,$gap,$finesse,$theta) = @_;
    $theta = 0.0 if scalar(@_)==3;
    
    my $spec = transmission($lambda,$gap,$finesse);

    my $filename = "$ENV{HOME}/Documents/F2T2/etalonmodels/gap".sprintf("%04.1f",$gap)."_F".sprintf("%2.f",$finesse).".txt";
    wcols "%8.6f %10.8f", $lambda, $spec, $filename;
    return $filename;
}

=pod

reflectionfit(): interactively fits a reflection spectrum produced by the FTIR MIRMAT800

=cut

sub reflectionfit {
    barf 'Usage: reflectionfit(wave,trans)' if scalar(@_)!=2;
    
    my($wav,$spec) = @_;
   
    dev '/xs';
    line $wav,$spec,{XTitle=>"Lambda (microns)",YRange=>[-0.5,1.5]};
 
    print "Choose 1st peak (shorter wavelength):\n";
    ($xpeak1,$ypeak1) = cursor({Type=>"CrossHair"});
    
    #zoom in on region
    $idx = which(abs($wav-$xpeak1) < 0.01);
    line $wav($idx), $spec($idx);

    print "Choose 1st peak again (this time at better resolution):\n";
    ($xpeak1,$ypeak1) = cursor({Type=>"CrossHair"});
    
    print "Choose FWHM of 1st peak (shorter wavelength):\n";
    ($x1,$y1) = cursor({Type=>"CrossHair"});
    hold;
    text "<--first point",$x1,$y1;
    ($x2,$y2) = cursor({XRef=> $x1,YRef=>$y1,Type=>"CrossHair"});
    release;
    line $wav,$spec,{XTitle=>"Lambda (microns)",YRange=>[-0.5,1.5]};
    text " <-- First Peak", $xpeak1,$ypeak1;
    print "Choose 2nd peak (longer wavelength):\n";
    ($xpeak2,$ypeak2) = cursor({Type=>"CrossHair"});
    print $x1,$x2,$xpeak1,$xpeak2;
    #zoom in on region
    $idx = which(abs($wav-$xpeak2) < 0.01);
    line $wav($idx), $spec($idx);

    print "Choose 2nd peak again (this time at better resolution):\n";
    ($xpeak2,$ypeak2) = cursor({Type=>"CrossHair"});
    
    $finesse = ($xpeak2 - $xpeak1) / ($x2 - $x1);

    print "Measured finesse is $finesse.\n";

    $count = 0;
    $gappeak1 = zeroes(20);
    $gappeak2 = zeroes(20);

    for ($order = 0; $order < 20; $order++) {
	$orderpeak1 = $count + 16;
	$orderpeak2 = $count + 15;
	$gappeak1($count) .= gap($xpeak1,$orderpeak1);
	$gappeak2($count) .= gap($xpeak2,$orderpeak2);
	$count++;
    }
    
    $dif = abs($gappeak1 - $gappeak2);
    
    $min = minimum_ind($dif);

    $gap1 = $gappeak1(($min));
    $gap2 = $gappeak2(($min));
    print "Gap determined from peak 1 is $gap1 and gap determined from peak 2 is $gap2.\n";
            
    line $wav,$spec;
    
    $a = maximum(pdl($ypeak1,$ypeak2));
    $modeltrans = $a *transmission($wav,$gap1,$finesse);

    hold;
    line $wav, $modeltrans,{Colour=>'red',LineStyle=>'Dashed'};
    release;
    return $gap1,$gap2,$finesse,$modeltrans;
}

1; #Exit status OK
