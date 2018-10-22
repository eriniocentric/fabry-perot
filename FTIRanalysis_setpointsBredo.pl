#script to generate etalon model spectra and fit to observed spectra
use PDL;
use PDL::NiceSlice;
use PDL::F2T2::Etalon;
use PDL::Graphics::PGPLOT;

open OUT, ">$ENV{HOME}/Documents/F2T2/etalonBftirredo.dat" or die "Problem opening output file\n";

@spectra = ("1.txt","2.txt","3.txt","4.txt","5.txt","6.txt","7.txt","8.txt");

foreach (@spectra) {
    $short = $_;
    $short =~ s/\.txt//;
    print "On file B-$short \n";
    $file = "$ENV{HOME}/Documents/F2T2/F2T2-20080112/$_";
    $flatfile = "$ENV{HOME}/Documents/F2T2/F2T2-20080112/flat.txt";
    $flatspec = rcols($flatfile,1);
    
    ($wave,$refspec) = rcols($file);
    $trans = 1.0 - $refspec / $flatspec;

    $select = which($wave > 0.95 & $wave < 1.5); #don't bother fitting outside this region
    $wave = $wave($select); $trans = $trans($select);
    
    $sort = qsorti($wave);
    $wave = $wave($sort); $trans = $trans($sort);
    
    ($gap1,$gap2,$finesse,$modeltrans) = reflectionfit($wave,$trans);
    
    printf OUT "%4.f %5.3f %5.3f %8.6f \n", $short, $gap1, $gap2, $finesse;
    
    dev "$ENV{HOME}/Documents/F2T2/Figures/etalonBredo-$short.ps/cps";
    line $wave,$trans,{XRange=>[0.95,1.45],YRange=>[-0.1,1.1],Colour=>'black',XTitle=> "Lambda (um)", YTitle=>"Transmission", Title=>"B-$short Gap = ".sprintf("%5.3f",$gap1)." F = ".sprintf("%5.3f",$finesse." ")};
    hold;
    line $wave,$modeltrans,{Colour=>'red',Linestyle=>'Dashed'};
    release;
}
