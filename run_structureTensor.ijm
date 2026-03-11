// --- Setup Paths ---
//fimg = "/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/10x_hem_R87A_ctrl_MBP_p01_c2_.LSM";
//fzip = "/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/87A_ctrl.zip";
//outputDir = "/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results/";
//sigma = 3.0;



function processOne(fimg, fzip, outputDir, sigma) {
// 1. Open the image
open(fimg);
mainImage = getImageID();
baseName = File.nameWithoutExtension;

// 2. Open ROIs
roiManager("reset");
roiManager("Open", fzip);
numROIs = roiManager("count");

// 3. Loop through ROIs
for (i = 0; i < numROIs; i++) {
    
    // 3.1 Select the ROI
    selectImage(mainImage);
    roiManager("select", i);
    //roiName = "ROI_" + (i + 1);
    roiName = "ROI_" + Roi.getName();
    
    // 3.2 Straighten the selection (creates a new window)
    run("Duplicate...",roiName);
    straightenedImage = getImageID();
    selectImage(straightenedImage);
    saveAs("Png", outputDir + baseName + "_" + roiName + "_cropped.png");
    
    // 3.3.1 OrientationJ Distribution (Histogram & Table)
    // Matches your recorded: tensor=3.0, histogram=on, table=on
    run("OrientationJ Distribution", "tensor=" + sigma + " gradient=0 radian=off histogram=on table=on min-coherency=0.0 min-energy=0.0 ");
    
    // Save Table
    if (isOpen("OJ-Distribution-1")) {
        selectWindow("OJ-Distribution-1");
        saveAs("Results", outputDir + baseName + "_" + roiName + "_vectortable.csv");
        close(); 
    } else {
        print("Could not find window OrientationJ Distribution Table");
    }
    
    // Save Histogram Image
    // The recorder showed "OJ-Histogram-1-slice-1", we use a wildcard to be safe
    if (isOpen("OJ-Histogram-1-slice-1")) {
        selectWindow("OJ-Histogram-1-slice-1");
        saveAs("Png", outputDir + baseName + "_" + roiName + "_histogram.png");
        close();
    } else {
        print("OJ-Histogram-1-slice-1");
    }

    // 3.3.2 & 3.3.3 Vector Field and Coherency
    selectImage(straightenedImage);
    run("OrientationJ Vector Field", "tensor=" + sigma + " gradient=0 coherency=on radian=off vectorgrid=20 vectorscale=100.0 vectortype=0 vectoroverlay=on vectortable=on ");
    
    // Save the Coherency Map (Created automatically by the Vector Field command above)
    if (isOpen("Coherency-2")) { // Usually increments or is named 'Coherency'
        selectWindow("Coherency-2");
        saveAs("Png", outputDir + baseName + "_" + roiName + "_coherency.png");
        close();
    } else if (isOpen("Coherency")) {
        selectWindow("Coherency");
        saveAs("Png", outputDir + baseName + "_" + roiName + "_coherency.png");
        close();
    }

    if (isOpen("OJ-Table-Vector-Field-")) {
    	saveAs("Results", outputDir + baseName + "_" + roiName + "_gridvectortable.csv");
    	close(); 
    } else {
        print("Could not save table OJ-Table-Vector-Field");
    }

    // Save the Vector Field Overlay
    selectImage(straightenedImage);
    run("Flatten"); // This merges the vector overlay into the pixels for saving
    saveAs("Png", outputDir + baseName + "_" + roiName + "_vector.png");
    close(); // Closes the flattened image

    // Cleanup straightened image
    selectImage(straightenedImage);
    close();
}

print("Finished: All ROIs processed.");
run("Dispose All Windows", "/all image non-image");

}



ids = newArray(
  "R87A_ctrl",
  "R87B_ctrl",
  "R87C_ctrl",
  "R90A_bcnu",
  "R90B_bcnu",
  "R90C_bcnu",
  "R90D_bcnu",
  "R90E_bcnu",
  "R90F_bcnu",
  "R90G_bcnu",
  "R90H_bcnu",
  "R90I_bcnu",
  "R90J_bcnu",
  "R91A_ctrl",
  "R91B_ctrl",
  "R91C_ctrl",
  "R91D_ctrl",
  "R91E_ctrl",
  "R91F_ctrl",
  "R91G_ctrl"
);
inputDir = "/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/";
outputDir = "/misc/lauterbur2/lconcha/exp/displasia/structureTensor/links_to_mosaics/results/";
sigma = 3.0;

// -------- loop --------
for (k = 0; k < ids.length; k++) {
    id = ids[k];

    // Build paths from the id
    fimg = inputDir +  id + "_MBP.LSM";
    fzip = inputDir + id + ".zip";


    print("[" + (k+1) + "/" + ids.length + "] id=" + id);
    if (File.exists(fimg)) {
      print("       Image exists: " + fimg);
   } else {
      print("ERROR: Image NOT found: " + fimg);
   }
   if (File.exists(fzip)) {
      print("       Image exists: " + fzip);
   } else {
      print("ERROR: Image NOT found: " + fzip);
   }


   processOne(fimg, fzip, outputDir, sigma);
}

