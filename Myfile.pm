
package Myfile;

sub check_backup {
	my ($filename) = @_;
	return if -e $filename;
	# rename "$filename.bak1", "$filename";
	return if -e $filename;
	# rename "$filename.bak2", "$filename";
}

sub fileload {
	my ($filename, $refdata, $min_size) = @_;
	&check_backup;
	my ($len_data);
	$min_size = -1 unless $min_size;
	open (FILE, "<$filename");
	binmode (FILE);
	@$refdata = <FILE>;
	close (FILE);

	$len_data = 0;
	foreach(@$refdata) { $len_data += length($_); }
	# print " [LOAD: $filename ",-s $filename," -> ",$len_data," $min_size] ";
	return 0 if $len_data < $min_size; # not ok
	return 0 if $len_data != -s $filename; # not ok
	return 1;
}

sub filesave {
	my ($filename, $refdata, $min_size, $max_delta) = @_;

	&check_backup;
	$min_size = -1 unless $min_size;
	$max_delta = 2000 + (-s $filename) unless $max_delta;

	$old_size = -s $filename;
	$old_size = -1 if $old_size == 0;

	$new_name = $filename . "." . int(100000 + rand(900000));
	unlink($new_name);
	open(FILE,">$new_name");
	binmode(FILE);
	print FILE @$refdata;
	close (FILE);
	$new_size = -s $new_name;
	# print " [SAVE: $new_name $old_size -> $new_size $min_size $max_delta] ";

	if (
		 (-s ($new_name) > $min_size) and
		 ( abs($old_size - $new_size) < $max_delta ) 

	) {
			unlink "$filename.bak2";
			rename "$filename.bak1", "$filename.bak2";
			rename "$filename",  	 "$filename.bak1";
			rename $new_name, 		 $filename;
			if (-e $new_name) {
				unlink $new_name;
				return 0; # not ok
			}
			else {
				return 1; # ok
			}
	}
	else {
				unlink $new_name;
				return 0; # not ok
	}
}

1;


