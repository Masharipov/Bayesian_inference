# Bayesian_inference

<p align="center"><img width="90%" src="illustrations/bayinf.png"/></p>

=========================================================================

Before performing Bayesian inference, it is recommended to scale linear contrasts of beta-values (θ = cB) to percent signal change (PSC)
See 'Scale_raw_betas_to_PSC.m' script

=========================================================================

**Before Use**

Before running these scripts, use SPM12 (v6906) to:
1) Create GLM for a one-sample or two-sample test.
2) Estimate model using the *Classical* method.
3) Estimate model using the *Bayesian 2nd-level* method.

**How to Use:**

1) Download the *BayInf_GUI* folder and add it to the MATLAB path.
2) Run the *bayinf.m* script for the GUI to appear.
3) Click *BPI* to run the Bayesian Parameter Inference function (alternatively, run the *bayinf_bpi.m* script directly from the command window).
4) Click *ROPE Maps* to calculate ROPE maps (alternatively, run the *bayinf_rope_maps.m* script directly from the command window).
5) Click *Visualisation* to open the GUI for visualising the structural image and its overlays (alternatively, run the *bayinf_vis.m* script directly from the command window). The same GUI will also appear after either *BPI* or *ROPE Maps* function is completed; in that case, the windows will open with overlays already added to the image, produced by these functions.
6) Click *Help* to open the manual (manual.pdf).
7) Click *Exit* to close the GUI.

=======================================================================

**Bayesian parameter inference *(bayinf_bpi.m*)**

1) Select *SPM.mat* file for one-sample or two-sample model.
2) Select contrast.  
3) Choose decision rule: 'ROPE-only' or 'HDI+ROPE'.
4) Choose effect size (ES) threshold γ, which defines the region of practical equivalence (ROPE)
4.1) The γ(Dicemax) threshold can be used when there are significant voxels revealed by classical NHST with FWE-correction of p<0.05 (_optionally_)
_γ(Dicemax) threshold ensures maximum similarity of the activation patterns revealed by classical NHST (pFWE<0.05) and BPI._
4.2) You can choose any ES threhold in PSC values (PSC corresponding to one prior SD of the contrast is offered by default)(_recommended_)

The output files will be created in the same folder where the SPM.mat file is stored.
The output files will be stored in 'ROPE-only' or 'HDI-ROPE' folder.
The *(bayinf_bpi.m*)* script creates raw Posterior Probability Maps (PPMs) and PPMs scaled to Log Posterior Odds (LPOs).

LPO = log((PostProb)/(1-PostProb))
LPO > 3 corresponds to PostProb > 95%

LPOs and PPMs are created for
1) Positive effects (θ > γ)
2) Null effects (–γ ≤ θ ≤ γ)
3) Negative effects (θ < –γ)

=========================================================================

**ROPE maps (*bayinf_rope_maps.m*)**

1) Select *SPM.mat* file for one-sample or two-sample model.
2) Select contrast.  
3) Choose decision rule: 'ROPE-only' or 'HDI+ROPE'.

The output files will be created in the same folder where the SPM.mat file is stored.
The output files will be stored in 'ROPE_maps' folder.

For positive/negative or “(de)activated” voxels, the ROPE map contains maximum ES thresholds allowing to classify voxels as “(de)activated” based on the “ROPE-only” or “HDI+ROPE” decision rules. For null or “not activated” voxels, it contains minimum effect size thresholds allowing to classify voxels as “not activated.”

=========================================================================

**Visualisation (*bayinf_vis.m*)**

*Visualisation* produces a window containing three orthogonal brain images, as well as various buttons for interacting with these images:

1) *Background Image* opens a file dialog allowing the user to select a structural image or binary mask (e.g. *mask.nii*). By default, the *mni152_2009_256.nii* structural image is selected. However, if the visualisation window is opened after producing overlays with the *BPI* or *ROPE Maps* functions, the *maks.nii* binary mask will be used instead.
2) *Positive Overlay, Null Overlay* and *Negative Overlay* allow the user to select overlays (red-, green- and blue-coloured, respectively). The buttons open a new window for customising the appearance of the overlays, which consists of these elements:
  - The *Path* button is used to select the path to the NIFTI file containing the overlay. If the visualisation window was opened after the completion of either the BPI or ROPE Maps function, then the paths to the overlays created by these functions will be selected automatically.
  - The *Minimum* and *Maximum* fields determine the lowest and highest levels of intensity displayed in the GUI. Any parts of the overlay whose intensity is lower than the minimum threshold are removed from the overlay entirely, while any intensity higher than the maximum will be shown by the brightest colour possible, without any differentiation between them. The default thresholds are 3 and 27, unless called from the ROPE Maps function, in which case the minimum is 0 and the maximum is the highest intensity in the overlay.
  - The *Reset* button removes the overlay and sets the minimum and maximum thresholds to the default levels.
  - The *Save* button saves the overlay, containing only the values above the minimum threshold, as a separate file.
  - The *Done* button confirms the changes and closes the window.
3) *Slices* allows the user to view the slices of the background image with the overlays, and save them as a separate image. It also opens a separate window with these elements:
  - *Positions* is a field containing the positions (in millimeters) at which slices will be made.
  - *Direction* signifies the direction at which the three-dimensional image will be cut (Saggital, Coronal or Axial).
  - *Rows* is a field determining how many rows will be contained in the final image.
  - *Create* confirms the settings and creates the image. That image can then be saved by right-clicking it and pressing the *Save* button.
4) *Position* is a field containing the current cross-hairs coordinates of the image's slices, in millimeters. If the user inputs their own coordinates in the field, the location of the crosshair will change accordingly.
5) *Intensity* (*Positive*, *Null* and *Negative*) signifies the intensity of the overlay at the crosshair's position (positive, null and negative respectively).

All coordinates used in the GUI correspond to the standard MNI coordinate space.
