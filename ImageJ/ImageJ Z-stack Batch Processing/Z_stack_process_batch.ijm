/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

process_folder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function process_folder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			process_folder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			process_file(input, output, list[i]);
	}
}

function process_file(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	path = input + File.separator;
	full_path = path + file;
	open(full_path); // The image is now open

	// Set up the variables
	title = getTitle();
	new_title = "composite_rgb_" + title;
	start_stack_array = newArray(0,6,11,16,0);
	stop_stack_array = newArray(5,10,15,20,100);

	// Create three different z stacking
	for(index=0;index<start_stack_array.length;index++){
		selectWindow(title); 
		run("Z Project...", "start="+ start_stack_array[index] + " stop=" + stop_stack_array[index] + " projection=[Max Intensity]");
		tag = "[" + start_stack_array[index] + "-" + stop_stack_array[index]+"]";
		stack_file_name = title+tag;
		rename(stack_file_name);
		run("Split Channels");
		run("Merge Channels...", "c1=C1-"+stack_file_name+" c2=C2-"+stack_file_name);
		run("RGB Color");				
		rgb_title = new_title + tag;	
		rename(rgb_title);
		saveAs("tiff",path+rgb_title); // This is how you save an active picture		
		close();	
	}
	
	close(); // The image is now closed
	print("Saving to: " + output);
}
