## Leave-one-out knockoffs for efficient structure learning in Julia

The framework of *model-X knockoffs* and the corresponding R package `knockoff` together provide FDR control for subset selection in sparse regression models with multivariate Gaussian covariates (1). Model-X knockoffs have also been applied for structure learning via graphical lasso (2) by leaving out each variable in turn. To facilitate progress in applications, especially in causal modeling of transcription, our packages provides efficient free software for leave-one-out knockoff generation. The main code-base for this project is in R -- please see the `rlookc` package for proper detail. Currently, this version only supports loading and assembly of knockoffs that were saved to disk using the R software. 

#### References

1. Candes, E., Fan, Y., Janson, L., & Lv, J. (2016). Panning for gold: Model-X knockoffs for high-dimensional controlled variable selection. arXiv preprint arXiv:1610.02351.
2. Zheng, Z., Zhou, J., Guo, X., & Li, D. (2018). Recovering the graphical structures via knockoffs. Procedia Computer Science, 129, 201-207.
