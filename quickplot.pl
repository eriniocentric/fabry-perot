use PDL;
use PDL::NiceSlice;
use PDL::Graphics::PGPLOT;

#dev '/xs';
dev '/Users/mentuch/Desktop/plusorminus5DACs.ps/cps';
line($wav,$spec,{XRange=>[1.17,1.195],YRange=>[0,1.4],Col=>black,XTitle=>"Lambda (um)",YTitle=>"Normalized Flux"});
hold;
line($wav,$spec2,{Col=>red});
line($wav,$spec3,{Col=>blue});
line($wav,$spec4,{Col=>green});
line($wav,$spec5,{Col=>orange});
line($wav,$spec6,{Col=>black,Linestyle=>2});
line($wav,$spec7,{Col=>red,Linestyle=>2});
#line($wav,$spec8,{Col=>green,Linestyle=>2});
line($wav,$spec9,{Col=>blue,Linestyle=>2});
line($wav,$spec10,{Col=>green,Linestyle=>2});
line($wav,$spec11,{Col=>orange,Linestyle=>2});
close;
$deltalambda = zeroes(12);
$peak = zeroes(12);
for ($i = 1; $i <= 12; $i++) {
    
    print "Choose cursor 1 \n";
    ($x1) = cursor();
    print "Choose cursor 2 \n";
    ($x2) = cursor();
    print "Choose peak \n";
    ($x3) = cursor();
    $peak(($i)) .= $x3;
    $deltalambda(($i)) .= $x2-$x1;

}

