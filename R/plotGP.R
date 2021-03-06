#' @title Plotting fitted GP models
#'
#' @description
#' Function for plotting fitted GP model within its confidence region of 2 standard deviations.
#' 
#' @param model GP model to be plotted.
#' @param col_item RGB color code which will be used for the color of the GP plot.
#' @param ylimits Numeric vector which contains minimum and maximum limits for the y axis.
#' @param write_xticks Boolean: whether to write x ticks and labels or not
#' @param write_yticks Boolean: whether to write y ticks and labels or not
#' @param jitterx Boolean: whether to jitter duplicated x values or not
#'
#' @export
#' @return Creates the plot of the fitted GP model.
#'
#' @examples
#' x=as.matrix(seq(1,10))
#' y=as.matrix(sin(x))
#' v=as.matrix(runif(10,0,0.5))
#' kernelTypes=c("rbf","white","fixedvariance")
#' model=constructModel(x,y,v,kernelTypes)
#' col_item=getColorVector()[1]
#' ylimits=c(min(y)-0.1,max(y)+0.1)
#' plotGP(model,col_item,ylimits)
#'
#' @importFrom graphics arrows
#' @importFrom grDevices col2rgb rgb
#'
#' @keywords plot
#' @author Hande Topa, \email{hande.topa@@helsinki.fi}
#' 

plotGP <-
function(model,col_item='gray',ylimits=NULL, write_xticks=TRUE, write_yticks=TRUE, jitterx=FALSE) {
	
	x=model$X
	y=model$y
	K = model$K_uu
	invK = model$invK_uu
	xtest = matrix(seq(c(head(x,1))-1e-14, c(tail(x,1))+1e-14, length = 100), ncol = 1)
	xtest=rbind(xtest,x)
	xtest=sort(xtest)
	Kx = kernCompute(model$kern, x, xtest)
	ypredMean = t(Kx)%*%invK%*%model$m+(rep(mean(model$y),dim(xtest)[1],1))
	ypredVar = kernDiagCompute(model$kern$comp[[1]], xtest) - rowSums((t(Kx)%*%invK)*t(Kx))
	lower=ypredMean-2*sqrt(ypredVar)
	upper=ypredMean+2*sqrt(ypredVar)

	no_of_kernels=length(model$kern$comp)
	kernTypes=list()
	for (i in 1:no_of_kernels) {
		kernTypes=append(kernTypes,model$kern$comp[[i]]$type)
	}
	if ("fixedvariance" %in% kernTypes) {
		ind_fixedvar_kern=which(kernTypes=="fixedvariance")
		v=model$kern$comp[[ind_fixedvar_kern]]$fixedvariance
	} else {
		v=matrix(0,length(x),1)
	}

	if (is.null(ylimits)) {
		ylimits=getYlimits(y,v,ypredMean,ypredVar)	
	}

        if (write_xticks) {
          if (write_yticks) {
            plot(xtest,ypredMean,type='n',xlim=c(head(x,1)-1e-14,tail(x,1)+1e-14),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="")
          } else {
            plot(xtest,ypredMean,type='n',xlim=c(head(x,1)-1e-14,tail(x,1)+1e-14),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",yaxt='n')
          }
        } else {
          if (write_yticks) {
            plot(xtest,ypredMean,type='n',xlim=c(head(x,1)-1e-14,tail(x,1)+1e-14),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",xaxt='n')
          } else {
            plot(xtest,ypredMean,type='n',xlim=c(head(x,1)-1e-14,tail(x,1)+1e-14),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",axes = FALSE,xaxt='n',yaxt='n')
          }
        }
	polygon(c(xtest, rev(xtest)), c(upper, rev(ypredMean)), col = col_item, border = NA)
	polygon(c(xtest, rev(xtest)), c(ypredMean, rev(lower)), col = col_item, border = NA)
	lines(xtest,lower,lty=2,col='black')
	lines(xtest,upper,lty=2,col='black')
	lines(xtest,ypredMean,lty=1,col='black')	

	x_jittered=x
	if (jitterx==TRUE) {
	  x_jittered[which(duplicated(x)==TRUE)]=jitter(x[which(duplicated(x)==TRUE)])
	}
	points(x_jittered,y,col='black',pch=20)
	
	if (any(v>0)) {
		arrows(as.vector(x_jittered), as.vector(y-2*sqrt(v)), as.vector(x_jittered), as.vector(y+2*sqrt(v)), length=0.05, angle=90, code=3, lwd=2, col=getDarkerColor(col_item))
	} 

}

getDarkerColor <-
function(color, factor=0.6) {

# Function for obtaining a darker tone of the given color.
# 
# @param color Color in rgb code.
# @param factor Factor of darkness.
#
# @export
# @return Darker tone of the given color.
#
# @examples
# color_vector=getColorVector()
# dark_color=getDarkerColor(color_vector[1])

	col=col2rgb(color)
	dark_color=rgb(t(col*factor), maxColorValue=255)
	return(dark_color)

}


#' @title Plotting fitted GP models for two-sample model
#'
#' @description
#' Function for plotting fitted GP models within its confidence region of 2 standard deviations
#' for the two-sample model.
#' 
#' @param model GP model to be plotted.
#' @param index sample index of the model to be plotted from the two-sample model.
#' @param col_item RGB color code which will be used for the color of the GP plot.
#' @param ylimits Numeric vector which contains minimum and maximum limits for the y axis.
#' @param write_xticks Boolean: whether to write x ticks and labels or not
#' @param write_yticks Boolean: whether to write y ticks and labels or not
#' @param jitterx Boolean: whether to jitter duplicated x values or not
#'
#' @export
#' @return Creates the plot of the fitted GP model.
#'
#' @examples
#' x=list(as.matrix(seq(1,10)), as.matrix(seq(1,10)))
#' y=list(as.matrix(sin(x[[1]])), as.matrix(cos(x[[2]])))
#' v=list(as.matrix(runif(10,0,0.2)), as.matrix(runif(10,0,0.2)))
#' kernelTypes=c("rbf","white","fixedvariance")
#' model=constructTwoSampleModel(x,y,v,kernelTypes)
#' col_item=getColorVector()[1]
#' index=1
#' ylimits=c(min(y[[index]])-0.1,max(y[[index]])+0.1)
#' 
#' plotTwoSampleGP(model,index,col_item,ylimits)
#'
#' @importFrom graphics arrows
#' @importFrom grDevices col2rgb rgb
#'
#' @keywords plot twoSample
#' @author Hande Topa, \email{hande.topa@@helsinki.fi}; Antti Honkela, \email{antti.honkela@@helsinki.fi}
#' 
#' 

plotTwoSampleGP <-
function(model,index,col_item='gray',ylimits=NULL, write_xticks=TRUE, write_yticks=TRUE, jitterx=FALSE) {
	
	x_all=model$X
        y_all=model$y
        I = x_all[,1] == index
        x = x_all[I,]
        y = y_all[I,]
	K = model$K_uu
        invK = model$invK_uu
        xmin = min(x[,2])-1e-14
        xmax = max(x[,2])+1e-14
	xtest = matrix(seq(xmin, xmax, length = 100), ncol = 1)
        xtest_kern=cbind(index, xtest)
	Kx = kernCompute(model$kern, x_all, xtest_kern)
	ypredMean = t(Kx)%*%invK%*%model$m+(rep(mean(model$y),dim(xtest)[1],1))
        ypredVar = kernDiagCompute(model$kern$comp[[index]], xtest_kern) - rowSums((t(Kx)%*%invK)*t(Kx))
        ypredVar = as.matrix(ypredVar)
	lower=ypredMean-2*sqrt(ypredVar)
	upper=ypredMean+2*sqrt(ypredVar)

	no_of_kernels=length(model$kern$comp)
	kernTypes=list()
	for (i in 1:no_of_kernels) {
	  kernTypes=append(kernTypes,model$kern$comp[[i]]$type)
	}
	if ("fixedvariance" %in% kernTypes) {
	  ind_fixedvar_kern=which(kernTypes=="fixedvariance")
	  v=model$kern$comp[[ind_fixedvar_kern]]$fixedvariance[I]
	} else {
	  v=matrix(0,length(x[,2]),1)
	}

	if (is.null(ylimits)) {
		ylimits=getYlimits(y,v,ypredMean,ypredVar)	
	}

        if (write_xticks) {
          if (write_yticks) {
            plot(xtest,ypredMean,type='n',xlim=c(xmin,xmax),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="")
          } else {
            plot(xtest,ypredMean,type='n',xlim=c(xmin,xmax),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",yaxt='n')
          }
        } else {
          if (write_yticks) {
            plot(xtest,ypredMean,type='n',xlim=c(xmin,xmax),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",xaxt='n')
          } else {
            plot(xtest,ypredMean,type='n',xlim=c(xmin,xmax),ylim=c(min(ylimits)-1e-14,max(ylimits)+1e-14),xlab="",ylab="",axes = FALSE,xaxt='n',yaxt='n')
          }
        }
	polygon(c(xtest, rev(xtest)), c(upper, rev(ypredMean)), col = col_item, border = NA)
	polygon(c(xtest, rev(xtest)), c(ypredMean, rev(lower)), col = col_item, border = NA)
	lines(xtest,lower,lty=2,col='black')
	lines(xtest,upper,lty=2,col='black')
	lines(xtest,ypredMean,lty=1,col='black')	

	x_jittered=as.matrix(x[,2])
	if (jitterx==TRUE) {
	  x_jittered[which(duplicated(x)==TRUE)]=jitter(x[which(duplicated(x)==TRUE)])
	}
	points(x_jittered,y,col='black',pch=20)

	if (any(v>0)) {
		arrows(as.vector(x_jittered), as.vector(y-2*sqrt(v)), as.vector(x_jittered), as.vector(y+2*sqrt(v)), length=0.05, angle=90, code=3, lwd=2, col=getDarkerColor(col_item))
	} 

}
