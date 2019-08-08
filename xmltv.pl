package this;
use Data::Dumper;
use XML::LibXML;
# binmode(STDOUT);
$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
# $Data::Dumper::Sortkeys = sub {
    # # Using <=> to sort numeric values
    # [ sort { $_[0]->{$a} <=> $_[0]->{$b} } keys %{ $_[0] } ]
# };
use Time::HiRes qw( time );
my $start = time();

my %lookup = (
   30 => {
       '00' => [ 00 .. 29 ],
       '30' => [ 30 .. 59 ]
         }
);

my %months = (	'01' => 'Jan',
				'02' => 'Feb',
				'03' => 'Mar',
				'04' => 'Apr',
				'05' => 'May',
				'06' => 'Jun',
				'07' => 'Jul',
				'08' => 'Aug',
				'09' => 'Sep',
				'10' => 'Oct',
				'11' => 'Nov',
				'12' => 'Dec'
			 );

my %rowlabel_lookup;
my %col_label_lookup;
my %search;
my %programme_data;
my %guide_data;
my %m3u_data;
my %icon_lookup;
my %col_span_for_onhover;
my @first_col_time;
my %chan_names;
# my @this_array;
my %guide_data_lookup;
my @cellsize;
my @groups;
my @combobox_strings;
my $xmltv_file = $ARGV[0];
my $m3u_file = $ARGV[1] or die "$!";
my $group = $ARGV[2] // NULL;
# print @ARGV and exit;

open my $file, '<', $m3u_file;
binmode($file);
open my $xml, '<', $xmltv_file;
# binmode($xml);
# open my $outfile, '>', $output;
# binmode($outfile, ':utf8');
print "Loading m3u file\n";
$n = 00;
<$file>; #skip first line
while (my $line1 = <$file>){
defined(my $line2 = <$file>) or last;


my ($tvg_id) = $line1 =~ /tvg-id="(.*?)"/; #align with channel and channel_id from xmltv
my ($tvg_name) = $line1 =~ /tvg-name="(.*?)"/;
my ($tvg_logo) = $line1 =~ /tvg-logo="(.*?)"/;
my ($tvg_group) = $line1 =~ /group-title="(.*?)".*\n/;
my ($tvg_link) = $line2 =~ /(.*?)\s+/;
chomp($tvg_link);

push @combobox_strings, $tvg_group unless $tvg_group ~~ @combobox_strings;

# $tvg_id =~ s/\é/e/; #convert accent to ascii/utf-8
if ($tvg_group =~ /$group/ ) { 
# $tvg_logo =~ s/\%20/ /g;
	$tvg_logo =~ m/.*(\/.*\.png|\/.*\.jpg).*/;
	
	# print "m3u tv logo -> $tvg_logo\n";
	#system("curl.exe $tvg_logo -o ./icons/$1") unless -e "./icons/$1";
	push @{$m3u_data{ $tvg_name }}, $tvg_id, $tvg_logo, $tvg_group, $tvg_link;
	} elsif ($group eq "all") { 
	push @{$m3u_data{ $tvg_name }}, $tvg_id, $tvg_logo, $tvg_group, $tvg_link;
	};
# if (exists $guide_data{$tvg_id}){
# $n++;
# print $tvg_id . " exists and has program data $n\n";
# }elsif (!exists $guide_data{$tvg_id}){
# $n++;
# print "$tvg_name does not exist in programming data $n\n";
# } 

if ($tvg_id eq ""){
$n++;
# print "$tvg_name has no tvg id : $n\n";
}
# print Dumper($dom);
# print $tvg_id . " - " . $n++ . "\n" if (exists $hash{$tvg_id});
	# for (keys %hash){
	# if ($tvg_id =~ /\b@{$hash{$_}}[2]\b/){
	# # print "$tvg_id == @{$hash{$_}}[2]\n";
	# }
# print "<--- start$hash{$_}[0] stop --->" ;
# print $hash{$_}[0] . "\n";
# print $hash{$_}[1] . "\n";
# print $hash{$_}[2] . "\n";
# print $hash{$_}[3] . "\n";
# print $hash{$_}[4] . "\n\n";
}

# print $outfile Dumper(\%m3u_data) if $outfile !~ NULL;
print "m3u loaded!\n";
my $channel_count = keys(%m3u_data);
print "$channel_count channels\n";
print "Loading xmltv file\n";
my $dom = XML::LibXML->load_xml(IO => $xml);

# my $i = 0;
my $n = '000';
my $last_chan;
our $c = '0';
my $spin;
$| = 1;
foreach my $programme ($dom->findnodes('/tv/programme')) {
	my($start) = $programme->findvalue('./@start');
	my($stop) = $programme->findvalue('./@stop');
	my($chan) = $programme->findvalue('./@channel');
	my($title) = $programme->findvalue('./title');
	my($desc) = $programme->findvalue('./desc');
	# chomp($chan);
	
	push @first_col_time, $start;
	# if (exists $hash{$chan}){
	# print (keys @{$hash{$chan}}) . "\n";
	# }
	# print $start . "\n";
	# print $chan."\n";
	# system 'pause';
	# print $outfile $programme . "\n";
	# if ( !exists $programme_data { $chan."-0" } ){
# print "$chan does not exists, creating key\n";

	if ($last_chan ne $chan){
	 # print $id . " ----- " . "$last_id\n";
	 $n = '000';
	 }
	 $last_chan = $chan;
	 # my ($test) = $start =~ /(.*)\s+\-0500/;
	 
	 # my ($start_year, $start_month, $start_day, $start_hours, $start_sec) = $start =~ /(\d{,4})(\d\d)(\d\d)(\d\d\d\d)(\d\d)/;
	 # my ($stop_year, $stop_month, $stop_day, $stop_hours, $stop_sec) = $stop =~ /(\d\d\d\d)(\d\d)(\d\d)(\d\d\d\d)(\d\d)/;
	 # print $outfile "$stop_year - $stop_month - $stop_day - $stop_hours\n" if $output !~ NULL;
		push @{$programme_data{ $chan }} , "entry-$n", "start-$start", "stop-$stop", "title-$title", "description-$desc";
	# my $size = @{$programme_data{ $chan }};

	my $s = $size / 5;

#################
print "size: $s\n" if $s == 204;
	 if ($n > $c){
	 print "$c\r";
	 $c = $n;
	 
	 # print substr( "-/|\\", $spin++ % 4, 1 ), '\r';
	# print "$c\b\b";
	}
	$n++;
		# print @{$hash{ $chan } {$n}}[4]."\n";
		# print @{$hash{ $chan } {$n}}  , $start, $stop, $title, $desc, $chan;
		# print "====> " . @{$hash{ $chan } {$n}}[4];
		# print "-> " . @{$hash{ $chan } {$n}}[2]. "\n";
		# if( @{$hash{ $chan } {$n}}[4] =~ /nickelodeon.uk/ ){
		# print $outfile @{$hash{ $chan } {$n}}  , $start, $stop, $title, $desc, $chan;
		# }
		# }
		# }else {
		# if ($last_chan ne $chan){
		# $n = 0;
		# $last_chan = $chan;
		# next;
		# }
		
		
		
		# push @{$programme_data{ $chan."-".$n++ }} , $start, $stop, $title, $desc;
		# print "$chan already exists, adding new key $n\n";
		# print $outfile @{$hash{ $chan } {$n}}  , $start, $stop, $title, $desc, $chan;
		# print @{$hash{ $chan }};
		
		# if( @{$hash{ $chan } {$n}}[4] =~ /amc.uk/ ){
		# print $programme . "\n";
		# }
		
		# print "====> " . @{$hash{ $chan } {$n}}[4] . "<==== channel\n";
	}
	
	print "xmltv file loaded!\n";

	


	# print $start . " : " . $stop . " : " . $chan . "\n";
	# print $start->to_literal . " \n " . $stop->to_literal . " \n " . $chan->to_literal . " \n " . $title->to_literal . " \n " . $desc->to_literal . "\n\n";
# }

# print $outfile Dumper(\%programme_data);
print "parsing tv guide data...\n";
$n = 00;
# my $i = 0;
my $last_id;
foreach my $channel ($dom->findnodes('/tv/channel')) {

# $channel->expand_entities(0);
	 my($id) = $channel->findvalue('./@id');
	 my ($display_name) = $channel->findvalue('./display-name');
	 my ($icon_src) = $channel->findvalue('./icon/@src');
	 $icon_src =~ /.*\/(.*\.png|.*\.jpg|.*\.jpeg|.*\.bmp).*/;
	 # my $link = $icon_src =~ s/\%20/ /g;
	 #system("curl $icon_src -o icons/$1") unless -e "icons/$1";
	 $id =~ s/\x{e9}/é/;
# if ($id =~ /^Cinépop/ ) {
# print $id . "\n";
    # # No accented chars, do something
# } else {
    
# }
	 # $i ++ && print "no icon $i\n" if ($icon_src eq '');
	 
	 # if ($channel =~/ESPN.us/){
	 # print $channel . "\n";
	 # system 'pause';
	 # }
	 # if (!exists ( $guide_data { $id."-0" })){
	 # if ($display_name ne $last_id){
	 # # print $id . " ----- " . "$last_id\n";
	 # $n = 00;
	 # }
	 # $last_id = $display_name;
	 # print"$id\n";
	 push @{$guide_data { $display_name}}, $id, $icon_src;
	 
	 # }
	 # else {
	 # if ($last_id !~ /$id/){
		# $n = 0;
		# $last_id = $id;
		# next;
		# }
		# push @{$guide_data { $id."-".$n++ }}, "display -> $display_name", "icon -> $icon_src";
		# }
# if (exists $guide_data{$id}){
	# print "$id exists!\n";
	# } else {
	# print "$id does NOT exist!\n";
	# }
	 # print $icon_src->to_literal;
	 # $hash{$display_name->to_literal} = 0;
	# print @{ $hash{"channel: $n"}}, $id, $display_name, $icon_src;
	# print $display_name . "\n";
	# push @{ $hash{$display_name->to_literal}}, $icon_src;
	# push @{ $hash{$display_name->to_literal}}, $icon_src->to_literal;
    # print $id->to_literal . " : " . $display_name->to_literal . " : " . $icon_src->to_literal . "\n"   ;
	# print $icon_src->to_literal();
}
# print $outfile Dumper(\%guide_data);
#my $n = 0;
print "guide data parsed!\n";
print "$c columns\n";
#for( sort keys %m3u_data){
# print "in loop";
	# if ( exists $guide_data{$_} && $guide_data{$_}[0] eq $m3u_data{$_}[0]){
	# # $n++;
	# # print "$guide_data{$_}[1] - $m3u_data{$_}[0] : $n\n";
# #	$n++;
# #	print "$n\n";
	# #print $outfile "$_ -> $guide_data{$_}[0], $guide_data{$_}[1], $guide_data{$_}[2]\n";
	# # print $outfile "$_ => " . Dumper($guide_data{$_});
	# }elsif ( exists $guide_data{$_} && $guide_data{$_}[1] ne $m3u_data{$_}[0]){
	# $n++;
	# print "$guide_data{$_}[1] - $m3u_data{$_}[0] : $n\n";
# #	$n++;
# #	print $n ."\n";
# }
#}
# print $outfile Dumper(\%guide_data);
	
# for (sort keys %hash){
# for my $num (0 .. 3){

# }
# }
# print @{$hash{$_}}[0] . "\n" for keys %hash;

 
### END OF FILE ###






# print Dumper sort %hash;
#if ($tvg_id =~ /@{$hash{/
# print "tvg id: $tvg_id\ntvg name: $tvg_name\ntvg logo: $tvg_logo\ntvg link: $tvg_link\n\n";
# sleep 1;
# }
# print "$_\n" for each %hash; #@{$hash{'channel: 1'}};
#this is channel id : @{$hash{'US: WORLD FISHING NETWORK | HD'}}[0];

# while( my( $k, $v ) = each %hash ){
# print "$k - @{$hash{$k}}\n";
# sleep 1;
# }


# for(keys %hash){
# print "$_\n" if $_ =~ /nickelodeon.uk/;
# }

# my @chan_array;

# my $file = shift;
# open my $fh, '<', $file;
# $/ = '8080/">';
# <$fh>;
# $/ = '</channel>';



# while(<$fh>){
# push @chan_array, $_;
# }

# seek $fh, 0, 0;

# while

# print "$_\n" for @chan_array;

close($file);
my $end = time();
printf( "took %.3f seconds!\n", $end - $start );

###################################
###################################
###################################



#######################################
#
package MyApp;
#
#######################################
use strict;
use vars qw(@ISA);
@ISA = qw(Wx::App);
use Wx qw(:everything);
sub OnInit {
    my($this) = @_;

Wx::InitAllImageHandlers();


my $frame = MyFrame->new(
    undef, -1, 'IPTV XMLTV/M3U VIEWER',
    [ 0, 0 ],
    #[1280, 768 ],
     [1100,500],
	Wx::wxDEFAULT_DIALOG_STYLE|Wx::wxSTAY_ON_TOP|Wx::wxMINIMIZE_BOX|Wx::wxNO_FULL_REPAINT_ON_RESIZE|Wx::wxCLIP_CHILDREN
);

    $frame->CenterOnScreen;
    $frame->Show(1);
    $this->SetTopWindow($frame);
	# $frame->DragAcceptFiles(1);
	# $frame->Maximize(1);

    return $frame;
}

#######################################
#
package MyFrame;
#
#######################################
use strict;
use threads;
use vars qw(@ISA);
@ISA = qw(Wx::Frame);

use Wx qw(:everything :combobox);
use Wx::Event qw(EVT_MOTION EVT_PAINT EVT_MEDIA_LOADED EVT_MEDIA_STOP EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_CLICK EVT_SCROLLWIN_LINEUP EVT_SCROLLWIN_LINEDOWN
				 EVT_COMBOBOX );
use Wx::Grid;
# use Module::Functions;

# our @EXPORT = get_public_functions('Wx::GridCellAttr');
# open my $ddd, '>', 'this';
# binmode $ddd;

# print $ddd "$_\n" for @EXPORT;
# exit;
use Wx::Media;
# use base 'Wx::ComboBox';
# use Wx::ScrollBar;
# use base qw(Wx::PlGridTable);
use Time::Moment;
use Date::Format;
# use DateTime;
# use DateTime::Format::Duration;
use Math::Round;
use IO::File;
# Wx::InitAllImageHandlers();
our $media;
my @sorted = sort @combobox_strings;
	my $last_col;
	my $last_row;
# Wx::InitAllImageHandlers();
# my $setcellrender = shift;
sub new {

    my ( $class ) = shift;
    my ( $this ) = $class->SUPER::new( @_ );



    $this->{main_window} = $this;
my $panel = Wx::Panel->new( $this, -1, wxDefaultPosition, wxDefaultSize);
my $panel2 = Wx::Panel->new( $panel, -1, [0,0], [ 200, 600 ]);
my $panel3 = Wx::Panel->new( $panel, -1, [200, 10], [900, 41]);
# my $sizer = Wx::BoxSizer->new(wxHORIZONTAL);
my $panel4 = Wx::Panel->new( $panel2, -1, [0,0], [ 200, 40 ]);

	#@strings2 = qw(Apple Orange Pear Grapefruit another again );
	my $combo = Wx::ComboBox->new($panel4, -1, "pick a group",
		    [10, 10], [180,30], \@sorted, wxCB_DROPDOWN|wxCB_READONLY, wxDefaultValidator);
		    
# my $panel4 = Wx::Panel->new($panel, -1, [1,1], [ 20, 20 ], wxSIMPLE_BORDER);

$panel->SetBackgroundColour(Wx::Colour->newRGB(25, 28, 30));
# $panel4->SetBackgroundColour(Wx::Colour->newRGB(25, 28, 30));

    # $media = Wx::MediaCtrl->new( $panel, wxID_ANY, '', [870,500], [385, 230], wxMEDIABACKEND_WMP10 );
# $media->Show(1);  
# $media->ShowPlayerControls(wxMEDIACTRLPLAYERCONTROLS_DEFAULT); 
# $media->Connect(wxEVT_MEDIA_LOADED, on_load(), -1, $panel);
   my $grid = Wx::Grid->new($panel, -1, [ 200,50 ], [ 1100, 518 ]); #main grid
   my $grid2 = Wx::Grid->new($panel2, -1, [ 0, 50 ], [ 220, 500 ] ); #channel list grid
	my $grid3 = Wx::Grid->new( $panel3, -1, [0, 0], [ 900, 60]); #time columns
	# $sizer->Add($grid3, 0, wxEXPAND|wxALL, 5);
# $grid3->SetMargins(1100, 1100 );
	$grid->SetDefaultCellFont(Wx::Font->new(11,wxFONTFAMILY_DECORATIVE ,wxNORMAL, wxFONTWEIGHT_BOLD,0));
	# $grid->SetLabelBackgroundColour(wxWHITE);
	# $grid2->SetLabelBackgroundColour(wxBLUE);
    $grid3->CreateGrid(1, $this::c);
	$grid2->CreateGrid(0, 1);
	$grid->CreateGrid(1, $this::c);
    # $grid->SetRowLabelSize(200);
	$grid->EnableEditing(0);
	$grid2->EnableEditing(0);
	$grid3->EnableEditing(0);

	my $bg_color_1 = Wx::Colour->new(5, 63, 94);
	my $bg_color_2 = Wx::Colour->new(220,220,220);
	my $font = Wx::Font->new(15,wxFONTFAMILY_DECORATIVE,wxNORMAL, wxFONTWEIGHT_BOLD,0);
	$grid->SetGridLineColour(wxBLACK);
	$grid2->SetGridLineColour(wxRED);
	$grid3->SetGridLineColour(wxRED);
	$grid->SetDefaultCellTextColour($bg_color_2);
	$grid3->SetDefaultCellTextColour(wxWHITE);
	$grid->SetDefaultCellBackgroundColour(Wx::Colour->newRGB(50, 50, 50));
	$grid3->SetDefaultCellBackgroundColour(Wx::Colour->newRGB(25, 28, 30));
	$grid->SetDefaultRowSize(60);
	$grid->SetDefaultColSize(180);
	$grid2->SetDefaultRowSize(60);
	$grid2->SetDefaultColSize(200);
	$grid3->SetDefaultRowSize(40);
	$grid3->SetDefaultColSize(180);
	$grid->SetRowLabelSize(0);
	$grid->SetColLabelSize(0);
	$grid2->SetRowLabelSize(0);
	$grid2->SetColLabelSize(0);
	$grid3->SetRowLabelSize(0);
	$grid3->SetColLabelSize(0);

   

my $curtime = time2str( "%c", time());
my @sorted = sort(@first_col_time);
my $first_col = shift @sorted;

my $round_down_time = round_down($first_col, 30);

$round_down_time =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
# print $1.$2.$3.$4.$5 and exit;
my $dt = Time::Moment->new( year => $1, month => $2, day => $3, hour => $4, minute => $5 );
my $min = 30;


    for (0..$this::c) {

	# if ($_ == 0){
	$dt =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/;
	# print $1.$2.$3.$4.$5 and system 'pause';
	$grid->SetColLabelValue($_, "$1$2$3$4$5");
	$grid3->SetColLabelValue($_, "$1$2$3$4$5");
	$grid3->SetCellValue(0, $_, "$1$2$3$4$5");
	$col_label_lookup{"$1$2$3$4$5"} = $_;
	$dt = $dt->plus_minutes($min);
# print "$_ $1$2$3$4$5\n";
	 # } 
	#else{
	# $dt = $dt->plus_minutes($min);
		# $dt =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/;


	# $grid->SetColLabelValue($_, "$1$2$3$4$5");
	# $grid3->SetColLabelValue($_, "$1$2$3$4$5");
	# $grid3->SetCellValue(0, $_, "$1$2$3$4$5");
	# $col_label_lookup{"$1$2$3$4$5"} = $_;
# print "$_ $1$2$3$4$5\n";
	# }
	}
	my $n = 0;
		for my $key(sort keys %m3u_data){
		if (exists $programme_data{@{$m3u_data{$key}}[0]}){ ### has guide data
		
		$grid->AppendRows(1, 1);
		$grid2->AppendRows(1, 1);
		$grid->SetRowLabelValue($n, $key);
		$grid2->SetCellRenderer( $n, 0, CustomRenderer->new );
		
		$rowlabel_lookup{$n} = $m3u_data{$key}[3]; ###create lookup for click events etc
		$icon_lookup{$n} = $m3u_data{$key}[1];
		$chan_names{$n} = $key;

		foreach my $num (0..$#{ $programme_data {$m3u_data{$key}[0] } } / 5){

		my $idx = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $start = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $stop = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $title = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $description = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});

		$title =~ s/^title\-//;

		$start =~ /^start\-(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\s+.*$/gs; 
		my ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
		my $r_min_1 = round_down("$year$month$day$hour$min", 30);
		$r_min_1 =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
		my $dt_stop = Time::Moment->new( year => $1, month => $2, day => $3, hour => $4, minute => $5 );
		# my $dur_stop = DateTime::Duration->new( minutes => 30);

		# my $format = DateTime::Format::Duration->new(
			# pattern => '%Y%m%d%H%M',
			# normalize => 1,             # Normalize (i.e. minutes can't be more than 59)
		# );
		
		$stop =~ /^stop\-(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\s+.*$/gs;
		my ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
		my $r_min_2 = round_down("$year$month$day$hour$min", 30);
		my $cell_end;
		
# print "start: $r_min_1 - end: $r_min_2 <---\n";
# print $dt_stop ."\n";
# system 'pause';
		# $dt = $dt->plus_minutes($min);
		# $dt_stop =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/;
		# print "$1$2$3$4$5 - $r_min_2\n";
		# system 'pause';
		for (0..10){
		
		# print $dt_stop;
		# $dt_stop = $dt_stop->plus_minutes($min);
		$dt_stop =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/;
		my $test = $col_label_lookup{$r_min_1} + $_;
			# print "$1$2$3$4$5 - $r_min_2 in foreach\n";
			if( "$1$2$3$4$5" =~  $r_min_2 ){
			$cell_end = $_;# 
			# $col_span_for_onhover{$n}{$test} = $col_label_lookup{$r_min_1};
			# my $cell_length = $cell_end + 1;
			# print "added $cell_end cells to row $n column $col_label_lookup{$r_min_1} \n";

			# $col_span_for_oh = ($num + $cell_end);
			# print "$col_span_for_oh is apart of $num\n";
				# print "$1$2$3$4$5 - $r_min_2 in for loop\n";
				
			# print "cell is $cell_end cells long\n";
			# system 'pause';

			last;
			} else {
			$dt_stop = $dt_stop->plus_minutes(30);
			# my $test = $col_label_lookup{$r_min_1} + $_;
			# print $col_label_lookup{$r_min_1} + $_ . "\n";
			# print $col_label_lookup{$r_min_1} . " -> $test\n";
			# system 'pause';
			$col_span_for_onhover{$n}{$test} = $col_label_lookup{$r_min_1};
			# print "adding a cell to row $n column $col_label_lookup{$r_min_1} \n";
			
			}
		}
		# $grid->SetCellBackgroundColour($n, $col_label_lookup{$r_min_1}, Wx::Colour->newRGB(220,220,220));
		$grid->SetCellValue($n, $col_label_lookup{$r_min_1}, $title);
		$grid->SetCellSize($n, $col_label_lookup{$r_min_1}, 1, $cell_end);			
		}
		$n++;
		} elsif ( !exists $programme_data{@{$m3u_data{$key}}[0]}){
		$grid->AppendRows(1, 1);
		$grid->SetRowLabelValue($n, $key);
		$grid2->AppendRows(1, 1);
		$grid2->SetCellRenderer( $n, 0, CustomRenderer->new );
		$rowlabel_lookup{$n} = $m3u_data{$key}[3];
		$icon_lookup{$n} = $m3u_data{$key}[1];
		$chan_names{$n} = $key;
		$n++;
		}
		 print "building row: $n\r";
	}

	foreach my $k( sort keys %col_label_lookup){
	# print $col_label_lookup{$_};
	my $conversion = $k;
	$conversion =~/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2}).*/;
	# print "\n";
	print "$col_label_lookup{$conversion} - $conversion - $k\n";
	# system 'pause';
	# print "setting column $col_label_lookup{$_} to $2/$3/$1 $4:$5\n";
	# $grid->SetColLabelValue($col_label_lookup{$_}, "$2/$3/$1 $4\:$5");
	my $font = Wx::Font->new(12, wxFONTFAMILY_SWISS, wxNORMAL, wxBOLD);
	# $grid3->SetCellFont(0, $_, $font);
	# print '$col_label_lookup{$_}' . " - " . $col_label_lookup{$_};
	# print "\n";
	$grid3->SetCellAlignment(0, $col_label_lookup{$conversion}, wxALIGN_CENTRE,wxALIGN_CENTRE);
	$grid3->SetCellValue(0, $col_label_lookup{$conversion}, "$2/$3/$1 $4\:$5");
	# $grid3->SetCellSize( 0, $col_label_lookup{$conversion}, 1, 1 );
	$grid3->SetCellFont(0, $col_label_lookup{$conversion}, $font);
	}
	
   EVT_COMBOBOX( $this, $combo, \&dropdown);
   my $id = $grid->GetGridWindow();
  
   EVT_MOTION($id, sub {onmove($_[1], $grid, $grid3)});
   # $this->Connect($grid->GetID(),wxEVT_MOTION,wxMouseEventHandler(onmove()), $this);
   
   EVT_SCROLLWIN_LINEUP( $grid, sub { log_scroll_event( $_[1], 'is grid 1 up', $grid, $grid2, $grid3 ) } );
   EVT_SCROLLWIN_LINEDOWN( $grid, sub { log_scroll_event( $_[1], 'is grid 1 down', $grid, $grid2, $grid3 ) } );
   
   EVT_SCROLLWIN_LINEUP( $grid2, sub { log_scroll_event( $_[1], 'is grid 2 up', $grid, $grid2, $grid3 ) } );
   EVT_SCROLLWIN_LINEDOWN( $grid2, sub { log_scroll_event( $_[1], 'is grid 2 down', $grid, $grid2, $grid3 ) } );
   
   EVT_GRID_CELL_LEFT_CLICK($grid, sub{cell_left_click($_[1], $grid)});
   EVT_GRID_CELL_LEFT_DCLICK( $grid, c_log_skip( 2 ) );
   EVT_GRID_CELL_RIGHT_CLICK( $grid, c_log_skip( 1 ) );
   # EVT_MEDIA_LOADED( $this, $media, on_load() );
   # EVT_MEDIA_STOP($grid, $media, c_log_skip(3) );

#need to resize grid3 so it scrolls correctly
$grid3->SetColSize(0, 1);
$grid3->SetColSize(0, 180);
#if i uncomment the line above the issue is gone 
my $tm = Time::Moment->now;
my ($y, $m, $d, $h, $min) = $tm =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}).*/;

$grid->MakeCellVisible(0, $col_label_lookup{round_down("$y$m$d$h$min", 30)});
$grid3->MakeCellVisible(0, $col_label_lookup{round_down("$y$m$d$h$min", 30)});

# $grid->SelectCol($col_label_lookup{round_down("$y$m$d$h$min", 30)});
# $grid3->SetVirtualSize($stuff, $stuff2);
# my ($stuff, $stuff2) = $grid3->GetVirtualSize();
# print "stuff $stuff - $stuff2\n";


    return $this;
}
# print @this_array;

sub onmove{
# print "@_";

use Data::Dumper;

	my ( $event, $grid, $grid3 ) = @_;
# print Dumper(\%col_span_for_onhover);
	# exit;
	my ( $coords ) = $event->GetPosition();
# my ($cellx, $celly) = $event->GetCell($coords->x, $coords->y);
# print "$cellx - $celly\n";

	my ($x, $y) = $grid->CalcUnscrolledPosition( $coords->x, $coords->y );
	
	my $col_pos = $grid->XToCol($x);
	my $row_pos = $grid->YToRow($y);

	# my $size = $grid->GridCellAttr->GetSize($row_pos, $col_pos);
	# print $size and exit;
# my $attr = $grid->Wx::GridCellAttr->new(Wx::GetCellAttr($row_pos, $col_pos));
# $attr->DecRef() ;
# print Dumper(\$attr);
# exit;
	#highlight cell on hover!
	if ($col_pos != $last_col or $row_pos != $last_row){
	
		my $last_label = $grid3->GetCellValue(0, $last_col) if defined($last_col);
		$last_label =~ /(\d{2})\/(\d{2})\/(\d{4})\s(\d{2}):(\d{2})/;
		if (defined $col_span_for_onhover{$last_row}{$last_col}){
		$grid->SetCellBackgroundColour($last_row, $col_span_for_onhover{$last_row}{$last_col}, Wx::Colour->newRGB(50, 50, 50));
		} else {
		$grid->SetCellBackgroundColour($last_row, $col_label_lookup{"$3$1$2$4$5"}, Wx::Colour->newRGB(50, 50, 50)) if defined($last_row);
		}
		$last_col = $col_pos;
		$last_row = $row_pos;
			
		my $label = $grid3->GetCellValue(0, $col_pos);
		# my $span = $grid->CellSpan()->GetCellSize($row_pos, $col_label_lookup{"$3$1$2$4$5"});
		$label =~ /(\d{2})\/(\d{2})\/(\d{4})\s(\d{2}):(\d{2})/;
		# $grid->SetCellBackgroundColour($row_pos, $col_label_lookup{"$3$1$2$4$5"}, Wx::Colour->newRGB(70, 70, 70));
		# print "span: $span\n";
		if (defined $col_span_for_onhover{$row_pos}{$col_pos}){
		print "$row_pos - $col_pos $col_span_for_onhover{$row_pos}{$col_pos} \n";
				$grid->SetCellBackgroundColour($row_pos, $col_span_for_onhover{$row_pos}{$col_pos}, Wx::Colour->newRGB(70, 70, 70));
			} else {
				$grid->SetCellBackgroundColour($row_pos, $col_label_lookup{"$3$1$2$4$5"}, Wx::Colour->newRGB(70, 70, 70));
			}
		$grid->Refresh;
		}	
	# $event->Skip;

	return 1;
}

sub cell_left_click{
	my ($event, $grid) = @_;
	# print "$event $grid\n";
	# my $temp = shift @cellsize or continue;

	my( $x, $y ) = ( $event->GetRow, $event->GetCol );
	# $grid->SetCellSize($x, $y);
	my $title = $grid->GetCellValue($x, $y);
	my $sizex = $grid->CellToRect($x, $y);
	print "row: $x - col: $y\n";
	print "cell width: " . $sizex->width() . " - " . $sizex->height() . "\n";
	
	$event->Skip();
	return 1;
}

sub dropdown{
	my ($this, $event) = @_;
	# print @_;
	my $sel = $event->GetString;
	print $sel . "\n";
	$this->new($sel);
	# $event->Skip();
	# return 1;
}

sub log_scroll_event {
  my( $event, $type, $grid, $grid2, $grid3  ) = @_;
# my ($x, $y) = $event->GetPosition;
# print "x:$x y:$y moving:";


print uc($type). "\n";
if ($event->GetOrientation == wxSB_VERTICAL and $type eq "is grid 1 down"){
 my ($x, $y) = $grid2->GetViewStart();
 # print "$x : $y\n";
 my $num = $y + 1;
 $grid2->Scroll($x, $num);
print "wxSB_VERTICAL_DOWN\n";
} elsif($event->GetOrientation == wxSB_VERTICAL and $type eq "is grid 1 up"){
my ( $x, $y) = $grid2->GetViewStart();
 # print "$x : $y\n";
 my $num = $y - 1;
 $grid2->Scroll($x, $num);
print "wxSB_VERTICAL_UP\n";
} elsif($event->GetOrientation == wxSB_VERTICAL and $type eq "is grid 2 up"){
my ($x, $y) = $grid->GetViewStart();
 # print "$x : $y\n";
 my $num = $y - 1;
 $grid->Scroll($x, $num);
print "wxSB_VERTICAL_UP\n";
} elsif($event->GetOrientation == wxSB_VERTICAL and $type eq "is grid 2 down"){
my ($x, $y) = $grid->GetViewStart();
  # print "$x : $y\n";
 my $num = $y + 1;
 $grid->Scroll($x, $num);
print "wxSB_VERTICAL_DOWN\n";
} elsif($event->GetOrientation == wxSB_HORIZONTAL and $type eq "is grid 1 up"){
my ($x, $y) = $grid3->GetViewStart();
 print "$x : $y\n";
 my $num = $x - 1;
 $grid3->Scroll($num, $y);
print "wxSB_HORIZONTAL_RIGHT\n";
}elsif($event->GetOrientation == wxSB_HORIZONTAL and $type eq "is grid 1 down"){
my ($x, $y) = $grid3->GetViewStart();
 print "$x : $y\n";
 my $num = $x + 1;
 $grid3->Scroll($num, $y);
print "wxSB_HORIZONTAL_LEFT\n";
}
# print ( ( $event->GetOrientation == wxHORIZONTAL ) ? 'horizontal' : 'vertical' );
print "\n";
  # printf( 'Scroll %s event: orientation = %s, position = %d', $type,
                  # ( ( $event->GetOrientation == wxHORIZONTAL ) ? 'horizontal' : 'vertical' ),
                  # $event->GetPosition );

  # important! skip event for default processing to happen
  # $grid->Refresh();
  # $grid3->Refresh();
  $event->Skip;
}

sub round_down{
	my ($time, $key) = @_;
	
	$time =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2}).*/;
# print "$1 $2:$3\n";
# print "1 $1\n2 $2\n3 $3\n4 $4\n5 $5\n";
	foreach my $v (keys %{$lookup{$key}}) {
		for my $num (@{$lookup{$key}{$v}} ) {
		# print "$num\n" if $num == $5;#print "$1:$v" if grep /$2/,$_;
			return ("$1$2$3$4$v") if $num == $5;
		}
	}
}

sub c_log_skip {
  my ($grid, $text, $something) = @_;
print "grid: $grid\n\ntext: $text\n\nvar: $something\n" ;
if ($grid == 1){
	$something = $grid;
	 }# elsif($grid == 4){
	# print "is 5\n";
	# return sub {
    # print "scrolling up\n";
	# print $text->GetOrientation();
    # #$_[0]->ShowSelections;
    # $_[1]->Skip;
  # };
	# } elsif($grid == 5){
	# #print "is 5\n";
	# return sub {
    # print "scrolling down\n";
	# print $text->GetOrientation();
    # #$_[0]->ShowSelections;
    # $_[1]->Skip;
  # };
  # }

	
  return sub {
    G2S( $_[0], $_[1], $something);
    #$_[0]->ShowSelections;
    $_[1]->Skip;
  };
}
# sub on_load{
# my ($grid, $event) = @_;
# print $media->GetState();
# $media->Play();
# }

sub threaded_task {

	my ($title, $y, $grid) = @_;
	print "$title\n";
    threads->create(sub { 
        my $thr_id = threads->self->tid;

my @args = ("vlc", "vlc:quit", "--qt-minimal-view", "--meta-title=$title", "--one-instance", "--loop",  "--fullscreen", $rowlabel_lookup{$y});
# print "link for title -> $rowlabel_lookup{$y}\n";
# print "title -> $title\n";
my $env_name = $ENV{'COMPUTERNAME'};
# print %ENV->{'COMPUTERNAME'}; print "\n";
system("taskkill /s $env_name /T /F /IM vlc.exe 2> nul");
# sleep 1;
system(1, @args);
# $MyFrame::this->Iconize(1);
# $media->LoadURI($rowlabel_lookup{$y});

# $media->Play();

threads->detach();

    });

	}
sub G2S {
  my ($grid, $event, $something) = @_;
  if ($something == 1 or $something == 3){
	  my( $x, $y ) = ( $event->GetCol, $event->GetRow );
	  my $colname = $grid->GetColLabelValue($x);
	  # print "$colname\n";
	  # return 1;
  }
if ($something == 4){

  return;
  }
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );

# print "col: $x\nrow: $y\n";
my $title = $grid->GetCellValue($y, $x);

threaded_task($title, $y, $grid);
$grid->Destroy();
  return 1;
}

package CustomRenderer;


use Wx qw( :everything );



use base 'Wx::PlGridCellRenderer';


sub Draw {

    my ( $self, $grid, $attr, $dc, $rect, $row, $col, $sel ) = ( shift, @_ );

	my $icon = $icon_lookup{$row};
	$icon =~ /.*\/(.*\.png|.*\.jpg)/;
    my $image = Wx::Image->new("icons/$1", wxBITMAP_TYPE_ANY);
	my $height = $image->GetHeight();
	my $width = $image->GetWidth();
	
# $image->ReScale(37,37, 'wxIMAGE_QUALITY_BICUBIC' );

my $bmp = Wx::Bitmap->new($image);
$bmp = Wx::Bitmap->new($image->Scale(37,37));
if( $bmp->IsOk() ) {

	$dc->SetPen(wxTRANSPARENT_PEN);
	
# print "$chan_names{$row}\n";
if ($chan_names{$row} =~ /^US\:.*(DISCOVERY\sCHANNEL.*)/) {
$dc->SetBrush(Wx::Brush->new(Wx::Colour->newRGB(191, 255, 128), wxSOLID));
} else {
$dc->SetBrush(Wx::Brush->new(Wx::Colour->newRGB(25, 28, 30), wxSOLID));
}
	$dc->DrawRectangle($rect->x, $rect->y, 200, 60);
# my $color = Wx::Brush(wxRED_BRUSH);
	# $dc->Clear();
	# $dc->SetBrush( wxTRANSPARENT_BRUSH);
	# $dc->SetCellBackgroundColour($row, 0, Wx::Colour->new(0,191,255));
	# $dc->DrawRect($rect);
	# $grid->Refresh($rect);
	$chan_names{$row} =~ /^.*\:\s(.*)\s\|/;

	my $font = Wx::Font->new(11, wxFONTFAMILY_SWISS, wxNORMAL, wxBOLD);
	$dc->SetTextForeground(wxWHITE);
	$dc->SetFont($font);
	print "$1\n";
	$dc->DrawText($1, $rect->x + 7, $rect->y + 23);
    $dc->DrawBitmap( $bmp, $rect->x + 140, $rect->y + 10, 1 );	
	# $dc->Clear;
	}
	
}
    sub Clone {
        my $self = shift;
        return $self->new;
    }
package main;
my($app) = MyApp->new();

$app->MainLoop();