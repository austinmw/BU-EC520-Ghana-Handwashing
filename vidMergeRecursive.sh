#!/bin/bash
IFS=$'\n'
for dir in $(find . -maxdepth 1 ! -path . -type d)
do
	for subdir in $(find "$dir" -mindepth 1 -type d)
	do
		base_dir=$(basename $dir)
		base_subdir=$(basename $subdir)

		# (this line will only work with bash or zsh shells, autocreate list)
		ffmpeg -f concat -safe 0 -i <(for f in "$base_dir"/"$base_subdir"/*.avi; do echo "file '$PWD/$f'"; done) -c copy /Volumes/Seagate/SAMPLING_DIR/COMBINED_SUBSAMPLES/"$base_dir"_"$base_subdir".avi
	done
done



# with a bash for loop
#for f in ./*.avi; do echo "file '$f'" >> mylist.txt; done

