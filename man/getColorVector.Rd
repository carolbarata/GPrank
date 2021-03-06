% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getColorVector.R
\name{getColorVector}
\alias{getColorVector}
\title{Extracting distinctive colors from RColorBrewer package}
\usage{
getColorVector(opacity = 0.7, display = FALSE)
}
\arguments{
\item{opacity}{Factor modifying the opacity, valued between [0,1]. Default is set to 0.7.}

\item{display}{By default set to FALSE; if TRUE, displays the color palette.}
}
\value{
Return vector of 28 distinctive RGB color codes.
}
\description{
Function for obtaining a vector of RGB color codes where the colors are as distinctive as possible from each other. 
This function extracts colors from Paired (12 colors), Set2 (8 colors), and Dark2 (8 colors) palettes provided in
the RColorBrewer package. If you need more than 28 colors, please remember to add your own palette.
}
\examples{
color_vector=getColorVector()

}
\author{
Hande Topa, \email{hande.topa@helsinki.fi}
}
\keyword{color}
