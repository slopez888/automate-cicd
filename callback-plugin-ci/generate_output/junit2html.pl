#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use FindBin '$Bin';
use XML::LibXML;
use File::Path qw/ make_path /;
use File::Basename qw/ basename dirname /;
use Encode;

my ($buildnum, $junit_log_dir, $playbook_dir, $output_dir) = @ARGV;

$junit_log_dir .= "/$buildnum";

my @files;
my %tests;

for my $file (sort glob "$junit_log_dir/*.xml") {
    my $basename = basename $file;
    my $time = 0;
    if ($basename =~ s/-(\d+)\.\d+\.xml$//) {
        $time = $1;
    }
    $tests{ $basename } = { file => $file, time => $time };
    push @files, $file;
}

make_path "$output_dir/js";
make_path "$output_dir/css";
system "cp $Bin/js/* $output_dir/js/";
system "cp $Bin/css/* $output_dir/css/";
make_path "$output_dir/$buildnum";
create_tests(\%tests);

my ($overview) = create_overview(\%tests);

open my $fh, ">:encoding(utf-8)", "$output_dir/$buildnum/index.html" or die $!;
print $fh $overview;
close $fh;

say "Created report at '$output_dir/$buildnum/index.html'";

sub create_tests {
    my ($tests) = @_;
    my %playbooks;
    for my $name (sort keys %$tests) {
        my $file = $tests->{ $name }->{file};
        my $filename = "$junit_log_dir/$file";
        my ($html, $playbooks) = create_test($file, $tests->{ $name });
        $playbooks{ $_ }++ for keys %$playbooks;
        open my $fh, '>:encoding(utf-8)', "$output_dir/$buildnum/$name.html" or die $!;
        print $fh $html;
        close $fh;
    }
    for my $key (sort keys %playbooks) {
        my $html = create_playbook($key);
        next unless $html;
        my $path = "$output_dir/$buildnum/playbooks/$key";
        $path =~ s/\.ya?ml$/.html/;
        my $dirname = dirname $path;
        if ($dirname) {
            make_path $dirname;
        }
        open my $fh, '>:encoding(utf-8)', $path or die $!;
        print $fh $html;
        close $fh;
    }

}

sub create_playbook {
    my ($playbook) = @_;
    my $playbook_path = "$playbook_dir/$playbook";
    return unless -f $playbook_path;
    open my $fh, '<:encoding(utf-8)', $playbook_path or die "Could not open '$playbook_path': $!";
    my @lines = <$fh>;
    close $fh;

    my ($nums, $lines);
    for my $num (0 .. $#lines) {
        my $num1 = $num + 1;
        $nums .= qq{$num1\n};
        $lines .= qq{<a class="line" name="line$num1">$lines[ $num ]</a>};
    }
    my $level = $playbook =~ tr{/}{};
    my $header = html_header( join '/', ('..') x ($level + 2));
    my $html = <<"EOM";
$header
<body>
<table><tr><th>#</th><th></th></tr>
<tr>
<td align="right"><pre>$nums</pre></td>
<td>
<pre>$lines</pre>
</td>
</tr>
</body>
</html>
EOM
}

sub create_test {
    my ($file, $test) = @_;
    my $dom = XML::LibXML->load_xml(location => $file);
    my $root = $dom->documentElement;
    my @suites = $root->findnodes('/testsuites/testsuite');
    if (@suites > 1) {
        die "Unexpected";
    }
    my %playbooks;
    my $cases_html = '<ul>';
    my $list = '<ul class="cases">';
    my $num = 0;
    my $failcount = 0;
    $test->{cases} = [];
    for my $suite (@suites) {
        my @cases = $suite->findnodes('testcase');
        for my $case_xml (@cases) {
            my $case = {};
            $num++;

            my $name = $case_xml->getAttribute('name');
            my $shortname = $name;
            # contains TODO?
            my $todo = $name =~ m/\bTODO\b/;
            if (length $name > 90) {
                $shortname = substr($name, 0, 90) . '...';
            }

            my ($systemOutNode) = $case_xml->findnodes('system-out');
            my ($errorNode) = $case_xml->findnodes('error');
            my ($failureNode) = $case_xml->findnodes('failure');
            my ($skippedNode) = $case_xml->findnodes('skipped');
            my $playbook = $case_xml->getAttribute('classname') // '';
            my $playbook_link = '';
            if ($playbook) {
                $playbook =~ s{^(.*/)?\Q$playbook_dir\E/}{};
                my ($playbook_filename, $line) = split m/:/, $playbook;
                $case->{playbook} = [$playbook_filename, $line];
                $playbook_link = "playbooks/$playbook_filename";
                $playbook_link =~ s/\.ya?ml$/.html/;
                $playbook_link .= "#line$line" if $line;
                $playbooks{ $playbook_filename }++;
            }
            my $systemOut = $systemOutNode ? $systemOutNode->textContent : '';

            my $hosts = [];
            my $playname = '?';
            if ($name =~ m/^\[include\] ([^:]+):/) {
                $playname = $2;
                if ($systemOut =~ m/: \[([\w, ]+)\] *$/) {
                    $hosts = [split m/, */, $1];
                }
            }
            elsif ($name =~ m/^\[(\w+)\] ([^:]+):/) {
                $hosts = [$1];
                $playname = $2;
            }
            $case->{hosts} = $hosts;
            $case->{playname} = $playname;
            my $failure = $failureNode ? $failureNode->textContent : '';
            my $skipped = $skippedNode ? $skippedNode->getAttribute('message') : '';
            if ($errorNode) {
                $failure .= $errorNode->getAttribute('message') . "\n" . $errorNode->textContent;
            }
            if ($failure) {
                $case->{result} = "fail";
                $failcount++;
                if ($todo) {
                    $case->{result} = "todo";
                }
            }
            elsif ($skipped) {
                $case->{result} = "skip";
            }
            else {
                $case->{result} = "ok";
                if ($todo) {
                    $case->{result} = "ok_todo";
                }
            }
            my $output = $failure || $systemOut || $skipped;
            $cases_html .= qq{<li>$num) <a name="$num"><tt>$name<br><a href="$playbook_link">$playbook</a></tt></a>};
            $cases_html .= <<"EOM";
<pre class="codebox $case->{result}">$output</pre>
EOM
            $cases_html .= "</li>";
            $list .= qq{<li class="$case->{result}"><a href="#$num">$num) $shortname</a>};

            push @{ $test->{cases} }, $case;
        }
    }
    $test->{count} = $num;
    $test->{fail} = $failcount;
    $cases_html .= '</ul>';
    $list .= '</ul>';
    my $header = html_header();
    my $html = <<"EOM";
$header
<body>
$list
$cases_html
</body>
</html>
EOM
    return ($html, \%playbooks);
}

sub create_overview {
    my ($tests) = @_;
    my @suites;


    my $body;
    my $i = 0;
    for my $name (sort keys %$tests) {
        $body .= '<tr>';
        my $test = $tests->{ $name };
        my $suite = $suites[ 0 ];
        say "$name";
        my $cases = $test->{cases};
        my $caseshtml = '';
        my $num = 0;
        for my $case (@$cases) {
            $num++;

            next if $case->{result} =~ m/^(ok|skip)$/;
            my $hosts = $case->{hosts};
            my $playname = $case->{playname};
            my $filename = '';
            if ($case->{playbook}) {
                my $line = $case->{playbook}->[1] // '-';
                $filename = qq{<a href="$name.html#$num">$case->{playbook}->[0] line $line</a>};
            }
            $caseshtml .= qq{<li class="$case->{result}"><tt>($num) $filename ($case->{result}) [@$hosts] $playname</tt></li>\n};
        }
        my $cssClass = 'ok';
        if ($test->{fail}) {
            $cssClass = "fail";
        }
        my $localtime = scalar localtime $test->{time};
        $body .= <<"EOM";
<td class="testsuite" valign="top">
<span class="$cssClass"><tt>$name ($test->{fail}/$num)</tt></span>
</td>
<td valign="top">$localtime</td>
<td valign="top"><a href="$name.html">Details</a></td>
<td valign="top"><ul class="cases" id="case$i" >
$caseshtml
</ul></td>
</tr>
EOM
        $i++;
    }

    my $header = html_header();
    my $html = <<"EOM";
$header
<body>
<table class="tests">
<tr><th>Playbook</th><th>Run</th><th>Details</th><th>Failed</th></tr>
$body
</table>
</body>
</html>

EOM
    return $html;
}

sub html_header {
    my ($relative) = @_;
    $relative ||= '..';
    return <<"EOM";
<html>
<head>
<link rel="stylesheet" href="$relative/css/junit.css">
<script src="$relative/js/jquery-3.3.1.min.js"></script>
<script src="$relative/js/junit.js"></script>
<title></title>
</head>
EOM
}
