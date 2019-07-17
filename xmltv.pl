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
my @first_col_time;

my %guide_data_lookup;

my $xmltv_file = shift;
my $m3u_file = shift or die "$!";
my $group = shift // NULL;
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
# $tvg_id =~ s/\é/e/; #convert accent to ascii/utf-8
if ($tvg_group =~ /$group/ ) { push @{$m3u_data{ $tvg_name }}, $tvg_id, $tvg_logo, $tvg_group, $tvg_link}
elsif ($group eq "all") { push @{$m3u_data{ $tvg_name }}, $tvg_id, $tvg_logo, $tvg_group, $tvg_link};
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

foreach my $programme ($dom->findnodes('/tv/programme')) {
	my($start) = $programme->findvalue('./@start');
	my($stop) = $programme->findvalue('./@stop');
	my($chan) = $programme->findvalue('./@channel');
	my($title) = $programme->findvalue('./title');
	my($desc) = $programme->findvalue('./desc');
	chomp($chan);
	
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
	print "size: $s\n" if $s == 204;
	 if ($n > $c){
	 $c = $n;
	print "$c\n";
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

my $frame = MyFrame->new(
    undef, -1, 'IPTV XMLTV/M3U VIEWER',
    [ 150, 600 ],
    [1280, 768 ],
    Wx::wxDEFAULT_DIALOG_STYLE|Wx::wxSTAY_ON_TOP|Wx::wxMINIMIZE_BOX
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

use Wx qw(:everything);
use Wx::Event qw(EVT_MEDIA_LOADED EVT_MEDIA_STOP EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_CLICK EVT_MOUSEWHEEL);
use Wx::Grid;
use Wx::Media;
# use base qw(Wx::PlGridTable);
use Date::Format;
use DateTime;
use DateTime::Format::Duration;
use Math::Round;
our $media;
# Wx::InitAllImageHandlers();

sub new {

    my( $class ) = shift;
    our( $this ) = $class->SUPER::new( @_ );
	


    $this->{main_window} = $this;
my $panel = Wx::Panel->new( $this, -1, wxDefaultPosition, wxDefaultSize);
my $sizer = Wx::FlexGridSizer->new(1,1, 0, 600);
    # $media = Wx::MediaCtrl->new( $panel, wxID_ANY, '', [870,500], [385, 230], wxMEDIABACKEND_WMP10 );
# $media->Show(1);  
# $media->ShowPlayerControls(wxMEDIACTRLPLAYERCONTROLS_DEFAULT); 
# $media->Connect(wxEVT_MEDIA_LOADED, on_load(), -1, $panel);
   my $grid = Wx::Grid->new($panel, -1, [ 1,1 ], [ 1251, 500 ]);
	# $sizer->Add( $grid, 1);
# print $this::c . "\n";
	$grid->SetDefaultCellFont(Wx::Font->new(11,wxFONTFAMILY_DECORATIVE ,wxNORMAL, wxFONTWEIGHT_BOLD,0));
	$grid->SetLabelBackgroundColour(wxWHITE);
    $grid->CreateGrid(0, $this::c);
    $grid->SetRowLabelSize(200);
	$grid->EnableEditing(0);
	# $grid->SetDefaultCellBackgroundColour(wxWHITE);
	$grid->EnableGridLines(1);
	my $bg_color_1 = Wx::Colour->new(5, 63, 94);
	my $bg_color_2 = Wx::Colour->new(220,220,220);
	my $font = Wx::Font->new(15,wxFONTFAMILY_DECORATIVE,wxNORMAL, wxFONTWEIGHT_BOLD,0);
	$grid->SetGridLineColour(wxWHITE);
	$grid->SetDefaultCellTextColour($bg_color_2);
	$grid->SetDefaultCellBackgroundColour($bg_color_1);
	$grid->SetDefaultRowSize(40);
	$grid->SetDefaultColSize(180);
	# $grid->SetRowLabelSize(0);
	# $grid->SetColLabelSize(0);
	#self.frame2.grid.Bind(wxEVT_SCROLLWIN, onScrollWin2)
# my $combobox = Wx::DemoModules::wxComboBox::Custom->new( $panel, -1, "This", [-1, -1], [-1, -1], 1, [ "this" ], wxCB_DROPDOWN);

    # EVT_COMBOBOX( $panel, $combobox, \&OnCombo );
    # EVT_TEXT( $panel, $combobox, \&OnComboTextChanged );
    # EVT_TEXT_ENTER( $panel, $combobox, \&OnComboTextEnter );
# $this->Iconize(1);
   

my $curtime = time2str( "%c", time());
my @sorted = sort(@first_col_time);
my $first_col = shift @sorted;

# $first_col =~ s/(\d+)\s+\-\d+/$1/;
# print $first_col and die;
my $round_down_time = round_down($first_col, 30);
# print $round_down_time;
$round_down_time =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
# print "1 $1\n2 $2\n3 $3\n4 $4\n5 $5\n" and die;;
# print "$1/$2/$3 $4:$5\n" and exit;

my $dt = DateTime::Duration->new( years => $1, months => $2, days => $3, hours => $4, minutes => $5 );
my $dur = DateTime::Duration->new( minutes => 30);

my $format = DateTime::Format::Duration->new(
    pattern => '%Y%m%d%H%M',
    normalize => 1,             # Normalize (i.e. minutes can't be more than 59)
);

# print "current time - $curtime\n";
# print "rounded down time - $round_down_time\n" and exit;

    for (0..$this::c) {
	# print "$_\n";
	# print "col $col\n";
	if ($_ == 0){
	$grid->SetColLabelValue($_, $format->format_duration($dt));
	$col_label_lookup{$format->format_duration($dt)} = $_;
	# $grid->SetColSize($_, 180);
	} else{
	$dt->add_duration($dur);
	$grid->SetColLabelValue($_, $format->format_duration($dt));
	$col_label_lookup{$format->format_duration($dt)} = $_;
	# $grid->SetColSize($_, 180);
	}
	}
	my $n = 0;
		for my $key(sort keys %m3u_data){
		# print "$m3u_data{$key}[0]\n";
		# print"@{$m3u_data{$key}}[0]\n";
		# print $key . "key\n";
		if (exists $programme_data{@{$m3u_data{$key}}[0]}){ ### has guide data
		# print @{$programme_data{@{$m3u_data{$key}}[0]}};
		# print "$key\n";
		# my $div = $#{ $programme_data {$m3u_data{$key}[0] } };
		# $div = $div / 5;
		# print $div;
		# print " - " . $programme_data {$m3u_data{$key}[0] }[-5] ;
		# print "adding row $key\n";
		
		$grid->AppendRows(1, 1);
		$grid->SetRowLabelValue($n, $key);
		$grid->SetRowSize($n, 200)  && Wx::Font->new(10,wxFONTFAMILY_DECORATIVE,wxNORMAL,wxNORMAL,0) if @{$m3u_data{$key}}[0] =~ /TMC\.us/;
		
		$rowlabel_lookup{$n} = $m3u_data{$key}[3]; ###create lookup for click events etc
		# $grid->SetRowSize($n, 43);
		# $$grid->SetReadOnly($key, -1);
		
		# system 'pause';
		# print "building row $key\n"; 
		foreach my $num (0..$#{ $programme_data {$m3u_data{$key}[0] } } / 5){
		# print "this $num\n";
		my $idx = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $start = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $stop = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $title = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		my $description = shift(@{$programme_data{@{$m3u_data{$key}}[0]}});
		# print $start . "\n";
		$title =~ s/^title\-//;
		# $start =~ s/^start\-//;
		# $stop  =~ s/^stop\-//;

		# print $start . "\n";
		$start =~ /^start\-(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\s+.*$/gs; 
		my ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
		my $r_min_1 = round_down("$year$month$day$hour$min", 30);
		$r_min_1 =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
		my $dt_stop = DateTime::Duration->new( years => $1, months => $2, days => $3, hours => $4, minutes => $5 );
		my $dur_stop = DateTime::Duration->new( minutes => 30);

		my $format = DateTime::Format::Duration->new(
			pattern => '%Y%m%d%H%M',
			normalize => 1,             # Normalize (i.e. minutes can't be more than 59)
		);
		
		$stop =~ /^stop\-(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\s+.*$/gs;
		my ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
		my $r_min_2 = round_down("$year$month$day$hour$min", 30);
		my $cell_end;
		

		
		foreach (0..6){
			if($format->format_duration($dt_stop) =~ $r_min_2 ){
			$cell_end = $_;# print "cell is $cell_end cells long\n";
			last;
			}
			$dt_stop->add_duration($dur_stop);
		}
		
		
		# print "before round - $year$month$day$hour$min\n";
		# print "after round - $r_min\n";
		# print "$year $months{$month} $day $hour $sec $msec\n";
		# print "$1 $2 $3 $4 $5\n";
		# system 'pause';
		# $grid->SetCellSize($n, $num, 1, 1);
		# print $col_label_lookup{$r_min}."\n";
		# print "cell size $cell_end\n";
		$grid->SetCellValue($n, $col_label_lookup{$r_min_1}, $title);
		$grid->SetCellSize($n, $col_label_lookup{$r_min_1}, 1, $cell_end);
		# $guide_data_lookup{$col_label_lookup{$r_min_1}} = $key;
		for (sort keys %guide_data_lookup){
				print "guide_data_lookup -> $_\n";
				}
		# print "$idx \n$start \n$stop \n$title \n$description\n\n";
		
		#@{$programme_data{@{$m3u_data{$key}}[0]}}
			# if(/^entry\-\d{1,3}$/){
			# print "$_\n";
			# } elsif(/^start\-\d{14} \-\d{4}$/){
			# print "$_\n";
			# } elsif(/^stop\-\d{14} \-\d{4}$/){
			# print "$_\n";
			# } elsif(/^title\-.*/){
			# print "$_\n";
			# } elsif(/^description\-.*/){
			# print "$_\n";
			# }
			
		}
		$n++;
		# system 'pause';
		# print "$programme_data{@{$m3u_data{$key}}[0]}\n";
		#print $programme_data{$key} . "\n";
		} elsif ( !exists $programme_data{@{$m3u_data{$key}}[0]}){
				print "@{$m3u_data{$key}}[0]\n";
		# print "adding row $key\n";
		# $grid->BeginBatch();
		# $grid->ForceRefresh();
		$grid->AppendRows(1, 1);
		$grid->SetRowLabelValue($n, $key);
		$rowlabel_lookup{$n} = $m3u_data{$key}[3];
		# $grid->SetRowSize($n, 50);	
		# $grid->SetCellSize($n, 0, 1, $this::c);
# for(0..$this::c - 1){		
		# $grid->SetCellValue($n, $_, "no title or description");
		# }
		
		# $grid->Refresh();
		# $grid->EndBatch();
		# $$grid->SetReadOnly($key, -1);
		$n++;
		# system 'pause';
		# print "building row $key\n"; 
		}
		else {
		# print "adding row $key\n";
		# $grid->SetRowLabelValue($n, $key);
		# $grid->SetRowSize($n, 50);
		# # $$grid->SetReadOnly($key, -1);
		# $n++;
		# system 'pause';
		# print "building row $key\n"; 
		 }
		 print "$n here\n";
		 # $grid->SetCellSize( 1, 0, 1, $this::c);
		# $grid->SetRowLabelValue($n, $key);
		# $grid->SetRowSize($n, 50);
		# # $$grid->SetReadOnly($key, -1);
		# $n++;
		# print $col . "-" . $row . "\n";
	# print "$_\n";
	# $grid->SetRowSize($_, 35);
	
    	# $grid->SetColLabelValue($_, "Col $_");
		# $grid->SetRowLabelValue($_, "Channel $_");
    
	}

	for( keys %col_label_lookup){
	# print $col_label_lookup{$_};
	my $conversion = $_;
	$conversion =~/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
	# print "\n";
	# print "setting column $col_label_lookup{$_} to $2/$3/$1 $4:$5\n";
	$grid->SetColLabelValue($col_label_lookup{$_}, "$2/$3/$1 $4\:$5");
	}
	
	foreach my $key (sort keys %programme_data){
	# print $key . "\n";
	# print time2str( "%I:%M %p", @{$programme_data{$_}}) . "\n";
	
	# foreach (@{$programme_data{$key}}){
	# if(/^entry\-\d{3}$/){
	# print "$_\n";
	# } elsif(/^start\-\d{14} \-\d{4}$/){
	# print "$_\n";
	# } elsif(/^stop\-\d{14} \-\d{4}$/){
	# print "$_\n";
	# } elsif(/^title\-.*/){
	# print "$_\n";
	# } elsif(/^description\-.*/){
	# print "$_\n";
	# }
	#}
		# system 'pause';
	
	}
    # $grid->SetColLabelValue(4, "Col 5")
	# $grid->SetCellSize(1,2,1,2);
    # my $ok_image = 'C:\\Test\\check_mark.png';
    # $grid->SetCellValue( 3, 3, Wx::Bitmap->new("$ok_image", wxBITMAP_TYPE_ANY));

   # my @array = $grid->GetSelectedCells;
my $curtime = time2str( "%Y%m%d%H%M", time());
$curtime = round_down($curtime, 30);
# print "\n==>".$curtime."<===\n";
$grid->MakeCellVisible(0, $col_label_lookup{$curtime});

   # EVT_MOUSEWHEEL( $grid, onscroll(1));
   EVT_GRID_CELL_LEFT_DCLICK( $grid, c_log_skip( 2 ) );
   EVT_GRID_CELL_RIGHT_CLICK( $grid, c_log_skip( 1 ) );
   # EVT_MEDIA_LOADED( $this, $media, on_load() );
   # EVT_MEDIA_STOP($grid, $media, c_log_skip(3) );

    return $this;
}

# sub onscroll{
# my ($this, $event) = @_;

# print "$this -and- $event\n";


# }

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
# print "grid: $grid\n\ntext: $text\n\nvar: $something\n" ;
if ($grid == 1){
	$something = $grid;
	} elsif($grid == 4){
	print "is 5\n";
	onscroll("this");
	return;
	}

	
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

	my ($title, $y) = @_;
	print "$title\n";
    threads->create(sub { 
        my $thr_id = threads->self->tid;
		

my @args = ("vlc", "--one-instance", "--loop", "--meta-title=$title", $rowlabel_lookup{$y});
print "link for title -> $rowlabel_lookup{$y}\n";
print "title -> $title\n";
system(1, @args);
$MyFrame::this->Iconize(1);
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
	  print "$colname\n";
	  # return 1;
  }
if ($something == 4){
  print $event;
  return;
  }
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );
 # my ($nnn) = GetRowLabelValue($y);
# print $nnn;
print "col: $x\nrow: $y\n";
my $title = $grid->GetCellValue($y, $x);

threaded_task($title, $y);

# my @args = ("vlc", "--one-instance", "--loop", "--meta-title=$title", $rowlabel_lookup{$y}); 

# print "link for title -> $rowlabel_lookup{$y}\n";
# print "title -> $title\n";

	# system(1, @args);
  return 1;
}


package main;
my($app) = MyApp->new();

$app->MainLoop();