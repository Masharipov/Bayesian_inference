# Bayesian_inference

<p align="center"><img width="90%" src="illustrations/bayinf.png"/></p>

=========================================================================

Before performing Bayesian inference, it is recommended to scale linear contrasts of beta-values (θ = cB) to percent signal change (PSC)
See 'Scale_raw_betas_to_PSC.m' script

=========================================================================

**Bayesian parameter inference (BPI)**

Before running 'BPI.m' script use SPM12 (v6906) to:
1) Create GLM for one sample test or two sample test
2) Estimate model using method: Classical
3) Estimate model using method: Bayesian 2nd-level

How to use:

0) Add to path 'BPI.m' script
1) Run 'BPI.m' script
2) Select SPM.mat file for one sample test or two sample test
3) Select contrast 
4) Choose decision rule: 'ROPE-only' or 'HDI+ROPE'

5) Choose effect size (ES) threshold γ, which defines the region of practical equivalence (ROPE)
5.1) You can use γ(Dicemax) threshold when there are significant voxels revealed by classical NHST with FWE-correction of p<0.05 (_optionally_)
_γ(Dicemax) threshold ensures maximum similarity of the activation patterns revealed by classical NHST (pFWE<0.05) and BPI._
5.2) You can enter any ES threhold in PSC values (PSC corresponding to one prior SD of the contrast is offered by default)(_recommended_)

The output files will be created in the same folder where the SPM.mat file is stored.
The output files will be stored in 'ROPE-only' or 'HDI-ROPE' folder.
'BPI' scripts creates raw Posterior Probability Maps (PPMs) and PPMs scaled to Log Posterior Odds (LPOs)

LPO = log((PostProb)/(1-PostProb))
LPO > 3 corresponds to PostProb > 95%

LPOs and PPMs created for
1) Positive effects (θ > γ)
2) Null effects (–γ ≤ θ ≤ γ)
3) Negative effects (θ < –γ)

Visualisation:
1) Open LPOs and PPMs in Mango or MRIcroGL as overlays. 
2) Threshold overlays (e.g. LPO > 3 or PPM > 95%) (change minimum intensity for overlays)

You can also use ImCalc to threshold LPOs and PPMs

=========================================================================

**ROPE maps**

Before running 'ROPE_maps.m' script use SPM12 (v6906) to:
1) Create GLM for one sample test or two sample test
2) Estimate model using method: Classical
3) Estimate model using method: Bayesian 2nd-level

How to use:

0) Add to path 'ROPE_maps.m' script
1) Run 'ROPE_maps.m' script
2) Select SPM.mat file for one sample test or two sample test
3) Select contrast 
4) Choose decision rule: 'ROPE-only' or 'HDI+ROPE'

The output files will be created in the same folder where the SPM.mat file is stored.
The output files will be stored in 'ROPE_maps' folder.
ROPE maps created for:
1) Positive effects (θ > γ)
2) Null effects (–γ ≤ θ ≤ γ)
3) Negative effects (θ < –γ)

For positive/negative or “(de)activated” voxels, the ROPE map contains maximum ES thresholds allowing to classify voxels as “(de)activated” based on the “ROPE-only” or “HDI+ROPE” decision rules.
For null or “not activated” voxels, it contains minimum effect size thresholds allowing to classify voxels as “not activated.”
