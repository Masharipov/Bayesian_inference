## Preparation
1) Download contrast files from the *Con_files* folder ("Emotional Faces > Shapes" contrast files calculated for 100 healthy subjects from the HCP dataset)
2) Create folders for one-sample and two-sample cases
3) If you are using the latest version of **SPM12 (v7771**), **replace the spm_reml.m"** function with the old one (v6906). You can find it in this repository (**see BayInf_GUI/spm_v6906 folder**)
4) Add BayInf toolbox to the path

## (1) One-sample example ##
In this example, we consider "Emotional Faces > Shapes" contrast (Emotion task) for the group of 100 healthy subjects.
If you select [+1] contrast (paragraph 9 below), the red colour will refer to "Emotion > Shape" effect, the green colour will refer to "Emotion = Shape", the blue colour will refer to "Shape > Emotion, and no colour will refer to "Low confidence".

1) Open SPM12
2) In the SPM12 menu, click *"Specify 2-nd level model"* button
- Select the directory for the model
- Select 100 contrast files from the *Con_files* folder
- Run the Batch
3) In the SPM12 menu, click *"Estimate"* button
- Select SPM.mat filed created on the previous step
- Choose: Method --> **Classical**
- Run the Batch
4) In the SPM12 menu, click *"Estimate"* button
- Select SPM.mat filed created on the previous step
- Choose: Method --> **Bayesian 2nd-level**
- Run the Batch
5) Close SPM12
6) Enter *bayinf* in the MATLAB Command Window
7) Click *"BPI"* button
8) Choose SPM.mat file
9) Select contrast
  - [+1] == "Emotional Faces > Shapes"
  - [-1] == "Emotional Faces < Shapes"
10) Choose decision rule
11) ES threshold based on DiceMax: Select "No"
12) ES threshold: press Enter to choose the default threshold (one prior SD of the contrast)
13) Results are stored in the "ROPE_only" or "HDI_ROPE" folder

## (2) Two-sample example ##
In this example, we use first 50 "Emotional Faces > Shapes" contrasts for the Group #1 and last 50 contrasts for the Group #2.
If you select [+1 -1] contrast (paragraph 9 below), the red colour will refer to "Group#1 > Group#2" effect, the green colour will refer to "Group#1 =Group#2", the blue colour will refer to "Group#2 > Group#1, and no colour will refer to "Low confidence".

Here we expect most of the voxels to be green ("Group#1 = Group#2"), as both groups are healthy subjects performing the same task.

1) Open SPM12
2) In the SPM12 menu, click *"Specify 2-nd level model"* button
- Select the directory for the model
- Select: Design --> **Two-sample t-test**
- Select first 50 contrast files from the *Con_files* folder for the **Group 1 scans**
- Select last 50 contrast files from the *Con_files* folder for the **Group 2 scans**
- Run the Batch
3) In the SPM12 menu, click *"Estimate"* button
- Select SPM.mat filed created on the previous step
- Choose: Method --> **Classical**
- Run the Batch
4) In the SPM12 menu, click *"Estimate"* button
- Select SPM.mat filed created on the previous step
- Choose: Method --> **Bayesian 2nd-level**
- Run the Batch
5) Close SPM12
6) Enter *bayinf* in the MATLAB Command Window
7) Click *"BPI"* button
8) Choose SPM.mat file
9) Select contrast
  - [1 -1] == "Group#1 > Group#2"
  - [-1 1] == "Group#1 < Group#2"
10) Choose decision rule
11) ES threshold based on DiceMax: Select "No"
12) ES threshold: press Enter to choose the default threshold (one prior SD of the contrast)
13) Results are stored in the "ROPE_only" or "HDI_ROPE" folder
 
