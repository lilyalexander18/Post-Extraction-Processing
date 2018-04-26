
/********************************************
VMMC Data Check 
Author: Lily Alexander
Date created: February 9, 2018 
Last updated: February 9, 2018 
*********************************************/


//-------------------------------

/* ----------------------- 
Environment Setup
--------------------------
*/

log close _all
clear all // this clears data, analysis previously loaded
set more off // this allows all results to print at once, rather than one screen at a time
set linesize 70 // this controls width of text lines in Stata; 
				// avoid wrapping or running off page
version 13  // sets Stata version; 
			// if necessary, use more recent version (Stata 15 released June 2017)

/* ------------------------
set working directory
---------------------------

*/
cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/VMMC"

/* ------------------------
create research log
---------------------------
*/

* open research log / all your output goes here 
quietly log using data_check, replace


* ----------------------------
* load/install packages
* ----------------------------

/* 
If needed, install necessary packages to compile notebook document (e.g., html, docx, pdf)
these packages include: markdoc, kethcup, weaver, synlight, and statax
note: if get any error messages, follow on-screen instructions in Stata console to 
complete correct installation

* once install following packages once, do not need to re-install; 
* here, commented out
*/
*packages for MarkDoc
*ssc install Markdoc
*ssc install weaver
*ssc install synlight
*ssc install statax
*markdocpandoc // installs pandoc
*packages for analysis and presentation of results
*ssc install estout, replace
*ssc install outreg
*ssc install pandoc
*ssc install coefplot 

*-----------------------
*-----------------------


/* Template: 
MI 20170122: 
comments from Stata do-file will not appear in final markdoc.
The text included in this do-file will only appear if it
is blocked between a forward slash '/' and 3 asterisks '***', as done below
immediately before start of latex syntax.
*/
	

/***

\documentclass{article}

\usepackage{graphicx}  % this is a package for inserting graphics
\usepackage{hyperref}
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=blue,      
    urlcolor=blue
	}
	
\usepackage{geometry}	% useful package for formatting document
\geometry{
	letterpaper,
	total={6.5in, 9in},
	left=1in,
	right=1in,
	top=1in,
	bottom=1in
	}

\begin{document}

\title{Data Validation Exercise before Entry into UCSR}
\author{
  Lily Alexander
  }

 \date{
  \bigskip
  \today
  }

\maketitle
	
\begin{abstract}
\textbf{Summary}. This is a document to validate and check variables before they are integrated into the UCSR.
\end{abstract}

\section{High-level codebook for all variables}

\begin{verbatim}
***/

/* ------------------------
load dataset
---------------------------
*/

/**/ use VMMC_clean_wide_file_Feb2018.dta, clear 


/* ------------------------
codebook generation
---------------------------
*/
/**/ codebook 
/*

\end{verbatim}



\begin{verbatim}
***/

* can generate clean tables

/**/ quietly cd "C:\Users\Lily Alexander\Dropbox\ALL LIFE THINGS\INSP\Work with Sergio\GHCC\Post-Extraction-Processing\VMMC\checks"
/**/ quietly eststo sumstats: quietly estpost summarize

/**/ quietly esttab sumstats using sumstats, ///
	cells("count mean sd min max") ///
	title("Summary Statistics") tex  replace
* note: do not use 'fragment' with esttab; doing so removes centering and 
* tabular syntax


* go back to main dir
/**/ quietly cd "C:\Users\Lily Alexander\Dropbox\ALL LIFE THINGS\INSP\Work with Sergio\GHCC\Post-Extraction-Processing\VMMC"


/***
\end{verbatim}

Here we import the table of summary statistics.\\

\input{./checks/sumstats} 

Now lets generate and add a figure that visualizing one of these variables.\\

----------------------
export final tex document
-----------------------------
*/

/* Exporting in several formats */
*markdoc example1, replace 		/* exporting a markdown file */
*markdoc example1, replace export(html) 
*markdoc example1, replace export(odt) 
*markdoc example1, replace export(txt) 
*markdoc example1, replace export(epub) 
*markdoc mytemplatelatex, replace author() affiliation() export(docx) 
/* could add date option (no parentheses) */
*markdoc mytemplatelatex, replace author() affiliation() export(pdf)

* markdoc mytemplatelatex, replace author() affiliation() export(docx) markup()
* markdoc mytemplatelatex, replace author() affiliation() export(html) markup()
markdoc data_check, replace author() affiliation() export(tex) markup()

/*
can also produce pdf slides:
markdoc example1, replace author(Matthew C. Ingram) affiliation(University at Albany, SUNY) date export(slide)
NOTE: this will replace any existing pdf file with same name, so be cautious
*/

* end


