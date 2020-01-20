#!/usr/bin/perl

use lib "/Users/jamestucker/Dropbox/SQE/yachad/perl/lib";
use warnings;
use HTML::Parser;
use SQE;
use JSON::PP;
use Data::Dumper; #general debugging tool
use open 'encoding(utf8)';
binmode(STDOUT, ":utf8");

#get input dir PATH
my $input = "/Users/jamestucker/Dropbox/SQE/yachad/Edition_Damascus/Damascus.xml";



#assign properties to functions
my $makeAcc		=	0;	#makes Accordance file
my $isTEI 		=	1;	#input is in the form of TEI
my $HTML5		=	0;
my $makeDB		=	1;	#makes a DB of text
my $makeExcel	=	1;


#get output dir PATH
my $outDIR = "/Users/jamestucker/Dropbox/SQE/yachad/perl/output";


#read input dir file contents to var
my $f = do {
	local $/ = undef;
	open my $fh, "<:utf8", "$input" or die "Nope: $!";
	<$fh>;
};

$f	=	&checkAccord($f, $makeAcc, $outDIR);

$f	=	&checkTEI($f, $isTEI);

$f	=	&excelFormat($f, $isTEI, $outDIR);


1; #kill the program

sub checkAccord() {
	my $f	= shift;
	my $acc = shift;
	my $outDIR = shift;

	if ($acc == 1){	
		open my $output, ">:utf8", "$outDIR/acc.txt" or die "Can't find the directory!: $!";
		my $e = $f;
		$e = &accordIT($f, 'he', '0');
		print $output $e;
		close($output);
	} elsif ($acc == 0) {
		my $accMade = "false";
	}

	# print $output $f;
	return $f;
}

sub checkTEI() {
	my $f = shift;
	my $tei = shift;
	my @htmlTree;
	
	if ($tei == 1){
		open my $output, ">:encoding(utf8)", "$outDIR/damascus-tei.xml" or die "Can't find the directory!: $!";
		my $e = $f;
		($e, @htmlTree) = &isTEI($e, 'text', 'li'); #textTag, #lineTag
		print $output $e;
		close($e);
	} elsif ($tei == 0){
		my $teiMade = "false";
	}
	
	return $f;
}

sub excelFormat() {
	my $f		=	shift;
	my $isTEI	=	shift;
	my $DIR		= 	shift;
	my @F;
	my $isDone;
	my $lineCount = 1;
	
	my $regex_XML	=	qr{<text dir="rtl">[^\r]+?</text>};
	my @text = ($f =~ m{$regex_XML}g);
	
	my $text = join( '', @text);

	$text =~ s{<text dir="rtl">[\r\n]([^\f]+?)</text>}{$1};
		
	my $colRX	=	qr{<col id[^>]+>[^\f]+?</col>};
	my @cols = ($text =~ m{$colRX}g);
	
	foreach my $col (@cols) {
		my $o = $col;
		my ($colID) = ($col =~ m{<col id="([^"]+?)"});
		$col	=~	s{<col id="[0-9A-z,-]+">[\n\r]}{};
		$col	=~	s{</col>}{}g;
		$col	=~	s{<p>[^\n]+</p>[\n\r]}{}g;
		$col	=~	s{(?<=[\n\r])\s+|^\s+}{}g;
		$col	=~	s{\x{00A0}}{ }g;
		$col	=~	s{\r}{\n}g;
		$col	=~	s{<l id="([^"]+?)">}{<l col="$colID" l="$1">}g;
		$col	=~	s{<l id="([^"]+?)" (alt="[^"]+?")>}{<l col="$colID" l="$1" $2>}g;
		my @lines = split(/\n/m, $col);
		foreach my $line (@lines) {
			my $oL	= $line;
			my $tagged	=	&tagLine($oL, $colID);
			push @F, $tagged;
			push @F, "\n";
		}
	}	
	
	#make HTML5 File to split into columns
	open my $outfile, ">:encoding(utf8)", "$DIR/excel.xml" or die "Can't find directory: $!";
	print $outfile @F;
	close($outfile);
	
	
	my $excelSource = "$DIR/excel.xml";
	my $s = do {
		local $/ = undef;
		open my $fh, "<:utf8", "$excelSource" or die "Nope: $!";
		<$fh>;
	};
	
	# my @vs = split(/\n/m, $s);
	# foreach my $v (@vs) {
	# 	my $ov = $v;
	# 	my $v = &for_Line($v);
	# }
	
	
	return $isDone;
}

sub tagLine() {
	my $l		=	shift;
	my $colN	=	shift;
	
	my ($lineN) = ($l	=~	m{<l col="[^"]+?" l="([^"]+?)">});
	
	if ($l =~ m{<l col="[^"]+?" l="[^"]+?">[^\f]+?</l>}){
		$l	=~	s{(<l col="[^"]+?" l="[^"]+?">)([^\f]+?)(</l>)}{$1<hb>$2</hb>$3};
	} elsif ($l =~ m{<l col="[^"]+?" l="[^"]+?">[^\f]+?</l>}){
		$l	=~	s{(<l col="[^"]+?" l="[^"]+?">)([^\f]+?)(</l>)}{$1<hb>$2</hb>$3};		
	} elsif ($l =~ m{<l col="[^"]+?" l="[^"]+?" alt="[^"]+?">[^\f]+?</l>}){
		$l	=~	s{(<l col="[^"]+?" l="[^"]+?" alt="[^"]+?">)([^\f]+?)(</l>)}{$1<hb>$2</hb>$3};
	} elsif ($l =~ m{<l col="[^"]+?" l="[^"]+?"></l>}){
		$l	=~	s{(<l col="[^"]+?" l="[^"]+?">)(</l>)}{$1<hb>NULL</hb>$2};
	} elsif ($l =~ m{<l col="[^"]+?" l="[^"]+?" alt="[^"]+?"></l>}){
		$l	=~	s{(<l col="[^"]+?" l="[^"]+?" alt="[^"]+?">)(</l>)}{$1<hb>NULL</hb>$2};
	} else {
		print "BUG AS OF 04-20-2017 CODE WAS WORKING";
	}

	## Conditions of Lines ##
	##	1. No reconstructed chars
	
	$l = &formatWords_0($l, 0) unless $l =~ m/\[|\]|\x{25E6}/;
	$l = &formatWords_1($l, 1) unless $l !~ m/\x{25E6}/;
	$l = &formatWords_2($l, 2) unless $l =~ m/\x{25E6}|<w/;
	$l = &formatWords_3($l, 3) if $l =~ m/\@/;
	$l = &formatWords_4($l, 3) unless $l =~ m{<done />};
	
	# print "ALL:\t$l\n";
	#debugger
	if ($l !~ m{<w}){
		# print "THIS LINE:\t$l\n";
	}
	
	return $l;
}

sub formatWords_0() {
	my $l	=	shift;
	my $cond = shift;
	my @return;
	
	my $tag_0	= 	qr{<l [^>]+?>};
	my $hb		=	qr{<hb>[^\f]+?</hb>};
	my $tag_2	=	qr{</l>};

	my ($oTag, $verse, $cTag) = ($l	=~ m{($tag_0)($hb)($tag_2)});
	my $oldVerse = $verse;
	my ($cN, $lN) = ($oTag =~ m{<l col="([^"]+?)" l="([^"]+?)"});
	$verse	=~	s{<hb>|</hb>}{}g;
	@words = split(/ /m, $verse);

	my $wordCounter = 0;
	push @return, "\t$oTag\n";
	foreach my $word (@words) {
		my $letterC = &getLetterCount($word);
		push @return, "\t\t\t<w id=\"$cN$lN$wordCounter\" lc=\"$letterC\">$word</w>\n";
		push @return, "\t\t\t<space lc=\"1\" />\n";
		$wordCounter++;
	}
	push @return, "\t$cTag\n\t<done />";
	
	$l = join( '', @return);
	$l	=~	s{<space lc="[^"]+?" />\n\t(</l>)}{$1};
	$l	=~	s{\t\t\t</l>}{\t\t</ln>};
	return $l;
}

sub formatWords_1() {
	my $l	=	shift;
	my $cond = shift;
	my @return;

	my $tag_0	= 	qr{<l [^>]+?>};
	my $hb		=	qr{<hb>[^\f]+?</hb>};
	my $tag_2	=	qr{</l>};
	
	my ($oTag, $verse, $cTag) = ($l	=~ m{($tag_0)($hb)($tag_2)});
	my $oldVerse = $verse;
	
	my ($cN, $lN) = ($oTag =~ m{<l col="([^"]+?)" l="([^"]+?)"});
	$verse	=~	s{<hb>|</hb>}{}g;
	
	
	if ($l !~ m{(([\x{0591}-\x{05FF}])+)}){
		push @return, "\t$oTag\n";
		my $charCount = &getLetterCount($verse);
		push @return, "\t\t\t<w id=\"NULL\" rc=\"$charCount\">$verse</w>\n";
		push @return, "\t\t$cTag\n\t<done />";
		$l = join( '', @return);
	} 
	
	return $l
}

sub formatWords_2 {
	my $l = shift;
	my $cond = shift;
	my @return;

	my $tag_0	= 	qr{<l [^>]+?>};
	my $hb		=	qr{<hb>[^\f]+?</hb>};
	my $tag_2	=	qr{</l>};
	
	my ($oTag, $verse, $cTag) = ($l	=~ m{($tag_0)($hb)($tag_2)});
	my $oldVerse = $verse;
	
	my ($cN, $lN) = ($oTag =~ m{<l col="([^"]+?)" l="([^"]+?)"});

	$verse	=~	s%\[[^\]]+?\]%(my $match = $&) =~ s/ /] [/g; $match;%eg;
	$verse	=~	s{<hb>|</hb>}{}g;

	@words = split(/ /m, $verse);

	my $wordCounter = 0;
	push @return, "\t$oTag\n";
	foreach my $word (@words) {
		my $oWord = $word;
		my $letterC = &getLetterCount($word);
		push @return, "\t\t\t<w id=\"$cN$lN$wordCounter\" lc=\"$letterC\">$word</w>\n";
		push @return, "\t\t\t<space lc=\"1\" />\n";
		$wordCounter++;
	}
	push @return, "\t$cTag\n\t<done />";
	
	$l = join( '', @return);
	$l	=~	s{<space lc="[^"]+?" />\n\t(</l>)}{$1};
	$l	=~	s{\t\t\t</l>}{\t\t</ln>};
	
	return $l;
}

sub formatWords_3() {
	my $l	=	shift;
	my $cond = shift;
	my @return;

	my $tag_0	= 	qr{<l [^>]+?>};
	my $hb		=	qr{<hb>[^\f]+?</hb>};
	my $tag_2	=	qr{</l>};
	
	my ($oTag, $verse, $cTag) = ($l	=~ m{($tag_0)($hb)($tag_2)});
	my $oldVerse = $verse;
	
	my ($cN, $lN) = ($oTag =~ m{<l col="([^"]+?)" l="([^"]+?)"});
	$verse	=~	s{<hb>|</hb>}{}g;
	$verse =~ s%\[[^\]]+?\]%(my $match = $&) =~ s/ /] [/g; $match;%eg;
	
	@words = split(/ |\@/m, $verse);

	my $wordCounter = 0;
	push @return, "\t$oTag\n";
	foreach my $word (@words) {
		my $oWord = $word;
		my $letterC = &getLetterCount($word);
		push @return, "\t\t\t<w id=\"$cN$lN$wordCounter\" lc=\"$letterC\">$word</w>\n";
		push @return, "\t\t\t<space lc=\"1\" />\n";
		$wordCounter++;
	}
	
	push @return, "\t$cTag\n\t<done />";
	
	$l = join( '', @return);
	$l	=~	s{<space lc="[^"]+?" />\n\t(</l>)}{$1};
	$l	=~	s{\t\t\t</l>}{\t\t</ln>};
	
	return $l;
}

sub formatWords_4() {
	my $l	=	shift;
	my $cond = shift;
	my @return;

	my $tag_0	= 	qr{<l [^>]+?>};
	my $hb		=	qr{<hb>[^\f]+?</hb>};
	my $tag_2	=	qr{</l>};
	
	my ($oTag, $verse, $cTag) = ($l	=~ m{($tag_0)($hb)($tag_2)});
	my $oldVerse = $verse;
	
	my ($cN, $lN) = ($oTag =~ m{<l col="([^"]+?)" l="([^"]+?)"});
	$verse	=~	s{<hb>|</hb>}{}g;
	$verse	=~	s%\[[^\]]+?\]%(my $match = $&) =~ s/ /] [/g; $match;%eg;
	print "$cN\t$lN\t$verse\n";
	
	# @words = split(/ |\@/m, $verse);
	#
	# my $wordCounter = 0;
	# push @return, "\t$oTag\n";
	# foreach my $word (@words) {
	# 	my $oWord = $word;
	# 	my $letterC = &getLetterCount($word);
	# 	push @return, "\t\t\t<w id=\"$cN$lN$wordCounter\" lc=\"$letterC\">$word</w>\n";
	# 	push @return, "\t\t\t<space lc=\"1\" />\n";
	# 	$wordCounter++;
	# }
	#
	# push @return, "\t$cTag\n\t<done />";
	#
	# $l = join( '', @return);
	# $l	=~	s{<space lc="[^"]+?" />\n\t(</l>)}{$1};
	# $l	=~	s{\t\t\t</l>}{\t\t</ln>};
	
	return $l;
}

sub getLetterCount() {
	my $w	=	shift;
	
	$w	=~	s{\[|\]}{}g;
	$w	=~	s{\{|\}}{}g;
	$w	=~	s{\^}{}g;
	$w	=~	s{\&lt;}{}g;
	$w	=~	s{\x{05AF}}{}g;
	$w	=~	s{\x{0307}}{}g;
	$w	=~	s{>}{}g;
	$w	=~	s{NULL}{}g;
	$w	=~	s{ }{}g;
	$w	=~	s{==}{}g;
	my $l = length($w);

	
	return $l;
}
