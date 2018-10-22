#script to generate etalon model spectra and fit to observed spectra
use PDL;
use PDL::NiceSlice;
use PDL::F2T2::Etalon;
use PDL::Graphics::PGPLOT;

open SPECTRA, "$ENV{HOME}/Documents/F2T2/F2T2-20071214/etalonBsetpointstest/fileindexB" or die "File list of spectra not found\n";
open OUT, ">$ENV{HOME}/Documents/F2T2/etalonBftirfit.dat" or die "Problem opening output file\n";

while (<SPECTRA>) {
    next if /flat/;
    $short = $_;
    $short =~ s/\.txt//;
    print "On file B-$short \n";
    $file = "$ENV{HOME}/Documents/F2T2/F2T2-20071214/etalonBsetpointstest/$_";
    $flatfile = "$ENV{HOME}/Documents/F2T2/F2T2-20071214/flat3.txt";
    $flatspec = rcols($flatfile,1);
    
    ($wave,$refspec) = rcols($file);
    $trans = 1.0 - $refspec / $flatspec;
    
    $select = which($wave > 0.95 & $wave < 1.5); 
    $wave = $wave($select); $trans = $trans($select);
    
    $sort = qsorti($wave);
    $wave = $wave($sort); $trans = $trans($sort);
    
    ($gap1,$gap2,$finesse,$modeltrans) = reflectionfit($wave,$trans);
    
    printf OUT "%4.f %5.3f %5.3f %8.6f \n", $short, $gap1, $gap2, $finesse;
    
    dev "$ENV{HOME}/Documents/F2T2/Figures/etalonBfit-$short.ps/cps";
    line $wave,$trans,{XRange=>[0.95,1.45],YRange=>[-0.1,1.1],Colour=>'black',XTitle=> "Lambda (um)", YTitle=>"Transmission", Title=>"B-$short Gap = ".sprintf("%5.3f",$gap1)." F = ".sprintf("%5.3f",$finesse." ")};
    hold;
    line $wave,$modeltrans,{Colour=>'red',Linestyle=>'Dashed'};
    release;
    }
	
close SPECTRA;
close OUT;

open SPECTRA, "$ENV{HOME}/Documents/F2T2/F2T2-20071214/etalonAsetpointstest/fileindexA" or die "File list of spectra not found\n";
open OUT, ">$ENV{HOME}/Documents/F2T2/etalonAftirfit.dat" or die "Problem opening output file\n";
while (<SPECTRA>) {
    next if /flat/;
    $short = $_;
    $short =~ s/\.txt//;
    print "On file A-$short \n";
    $file = "$ENV{HOME}/Documents/F2T2/F2T2-20071214/etalonAsetpointstest/$_";
    $flatfile = "$ENV{HOME}/Documents/F2T2/F2T2-20071214/flat2.txt";
    $flatspec = rcols($flatfile,1);
    
    ($wave,$refspec) = rcols($file);
    $trans = 1.0 - $refspec / $flatspec;
	
    $select = which($wave > 0.95 & $wave < 1.5); #don't bother fitting outside this region
    $wave = $wave($select); $trans = $trans($select);
    
    $sort = qsorti($wave);
    $wave = $wave($sort); $trans = $trans($sort);
    
    ($gap1,$gap2,$finesse,$modeltrans) = reflectionfit($wave,$trans);
    
    printf OUT "%4.f %5.3f %5.3f %8.6f \n", $short, $gap1, $gap2, $finesse;
    
    dev "$ENV{HOME}/Documents/F2T2/Figures/etalonAfit-$short.ps/cps";
    line $wave,$trans,{XRange=>[0.95,1.45],YRange=>[-0.1,1.1],Colour=>'black',XTitle=> "Lambda (um)", YTitle=>"Transmission", Title=>"A-$short Gap = ".sprintf("%5.3f",$gap1)." F = ".sprintf("%5.3f",$finesse." ")};
    hold;
    line $wave,$modeltrans,{Colour=>'red'};
    release;
}

close SPECTRA;
close OUT;
