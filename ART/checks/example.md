<!doctype html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!-- SYNTAX HIGHLIGHTING CLASSES  -->

<style type="text/css">
.author {display:block;text-align:center;font-size:16px;margin-bottom:3px;}
.date {display:block;text-align:center;font-size:12px;margin-bottom:3px;}
.center, #center {
    display: block;
    margin-left: auto;
    margin-right: auto;
    -webkit-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );
    -moz-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );
    box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );

    padding: 0px;
    border-width: 0px;
    border-style: solid;
    cursor:-webkit-zoom-in;
    cursor:-moz-zoom-in;
    }

pagebreak {
        page-break-before: always;
        }

.pagebreak, #pagebreak {
        page-break-before: always;
        }

td > p {padding:0; margin:0;}




header {
        font-size:28px;
        padding-bottom:5px; 
        margin:0;
        padding-top:150px; 
        font-family: ;
        background-color:white; 
        text-align:center;
        display:block;
        }

table {
        border-collapse: collapse;
        border-bottom:1px solid black;
        padding:5px;
        margin-top:5px;

}
.tble {
        display:block;
        margin-top: 10px;
        margin-bottom: 0px;
        margin-bottom: 0px;
}

.tblecenter {
        display:block;
        margin-top: 10px;
        margin-bottom: 0px;
        margin-bottom: 0px;
        text-align:center;
}

span.tblecenter + table, span.tble + table, span.tble + img {
        margin-top: 2px;
}

th {
border-bottom:1px solid black;
border-top:1px solid black;
padding-right:20px;
}

td {
padding-right:20px;
}

</style>





<!-- Stata Style  -->

<style type="text/css">
body {

        margin:10px 30px 10px 30px;
        font-family: ;
        }

@page {
        size: auto;
        margin: 10mm 20px 15mm 20px;
        color:#828282;
        font-family: ;
 @top-left { content: "" ; font-size:11px; margin-top:5px; } 
@bottom {
        content: "Page " counter(page); font-size:14px; 
        }
        }

@page:first {
@top-left {
        content: normal
        }
@bottom {
        content: normal
        }
        }

header {
        font-size:28px;
        padding-bottom:5px; 
        margin:0;
        padding-top:150px; 
        font-family: ;
        background-color:white; 
        text-align:center;
        display:block;
        }

ul {        list-style:circle;
        margin-top:0;
        margin-bottom:0;
        }

div ul a {
        color:black;
        text-decoration:none;
        }

div ul {
        list-style: none;
        margin: 0px 0 10px -15px;
        padding-left:15px;
        }

div ul li {
        font-weight:bold;
        margin-top:20px;
        }

div ul li ul li {
        font-weight: normal;
        margin-left:20px;
        margin-top:5px;
        }

div ul li ul li ul li {
        font-weight: normal;
        font-style:none;
        margin-top:5px;
        }

div ul li ul li ul li ul li {
        font-weight: normal;
        font-style:italic;
        margin-top:5px;
        }

img {
        margin: 5px 0 5px 0;
        padding: 0px;
        cursor:-webkit-zoom-in;
        cursor:-moz-zoom-in;
        display:inline-block;
        text-align: left;
        clear: both;
        }

h1, h1 > a, h1 > a:link {
        margin:24px 0px 2px 0px;
        padding: 0;
        font-family: ;
        color:#17365D;
        font-size: 22px;
        }

h1 > a:hover, h1 > a:hover{
color:#345A8A;
} 

h2, h2 > a, h2 > a, h2 > a:link {
        margin:14px 0px 2px 0px;
        padding: 0;
        font-family: ;
        color:#345A8A;
        font-size: 18px;
        font-weight:bold;
        }

h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {
        margin:14px 0px 0px 0px;
        padding: 0;
        font-family: ;
        color:#4F81BD;
        font-size: 14px;
        font-weight:bold;
        }

h4 {
        margin:10px 0px 0px 0px;
        padding: 0;
        font-family: ;
        font-size: 14px;
        color:#4F81BD;
        font-weight:bold;
        font-style:italic;
        }

h5  {
        font-family: ;
        font-size: 14px;
        font-weight:normal;
        color:#4F81BD;
        }

h6  {
        font-size:14px;
        font-family: ;
        font-weight:normal;
        font-style:italic;
        color:#4F81BD;
        }

p {
        font-family: ;
        font-weight:normal;
        font-size:14px;
        line-height:14px;
        line-height: 16px;
        text-align:justify;
        text-align: left;
        text-justify:inter-word;
        margin:0 0 14px 0;
        }

.code {
        white-space:pre;
        color: black;
        padding:5px;
        display:block;
        font-size:12px;
        line-height:14px;
        background-color:#E1E6F0;
        font-family:"Lucida Console", Monaco, monospace, "Courier New", Courier, monospace;
        font-weight:normal;
        text-shadow:#FFF;
        border:thin;
        border-color: #345A8A; 
        border-style: solid;
        unicode-bidi: embed;
        margin:20px 0 0px 0;
        }

.output {
        white-space:pre;
        display:block;
        font-family:monospace,"Lucida Console", Monaco, "Courier New", Courier, monospace;
        font-size:12px; 
        line-height: 12px;
        margin:0 0 14px 0;
        border:thin; 
        unicode-bidi: embed;
        border-color: #345A8A; 
        padding:14px 5px 0 5px;
        background-color:transparent;
        }

</style>



<script type="text/javascript" src='http://haghish.com/statax/Statax.js'></script>
</head>
<header>Testing MarkDoc Package</header>
<body>
<span class="author">E. F. Haghish</span>
<span class="author">Medical Biometry and Medical Informatics,  University of Freiburg</span>
<span class="author">haghish@imbi.uni-freiburg.de</span>


Introduction to MarkDoc (heading 1)
===================================

__MarkDoc__ package provides a convenient way to write dynamic document
within Stata dofile editor. Before starting, remember that there are a few
things that ___you must absolutely avoid___ while using MarkDoc.

1. Use only one markup language. While you are writing with _Markdown_ you
may also use _HTML_ tags, but __avoid__ _LaTeX_ in combination of _HTML_ or
_Markdown_.

2. Only use English letters. Any unsual character (Chinese, French, or
special characters) should be avoided.

3. Please make sure you that you have the __permission to write and remove
files__ in your current working directory. Especially if you are a
__Microsoft Windows__ user. Ideally, you should be the adminster of
your system or at least, you should be able to run Stata as an adminstrator
or superuser. Also pay attension to your current working directory.

Using Markdown (heading 2)
--------------------------

Writing with _Markdown_ syntax allows you to add text and graphs to
_smcl_ logfile and export it to a editable document format. I will
demonstrate the process by using the __auto.dta__ dataset.

###Get started with MarkDoc (heading 3)

I will open the dataset, list a few observations, and export a graph.
Then I will export the log file to _HTML_ format.
          
<pre class="sh_stata">  .  quietly sysuse auto, clear</pre>
          
<pre class="sh_stata">  . list in 1/5</pre>
          
               +-----------------------------------------------------------------+
            1. | make          | price | mpg | rep78 | headroom | trunk | weight |
               | AMC Concord   | 4,099 |  22 |     3 |      2.5 |    11 |  2,930 |
               |-----------------------------------------------------------------|
               |  length   |  turn   |  displa~t   |   gear_r~o   |    foreign   |
               |     186   |    40   |       121   |       3.58   |   Domestic   |
               +-----------------------------------------------------------------+
          
               +-----------------------------------------------------------------+
            2. | make          | price | mpg | rep78 | headroom | trunk | weight |
               | AMC Pacer     | 4,749 |  17 |     3 |      3.0 |    11 |  3,350 |
               |-----------------------------------------------------------------|
               |  length   |  turn   |  displa~t   |   gear_r~o   |    foreign   |
               |     173   |    40   |       258   |       2.53   |   Domestic   |
               +-----------------------------------------------------------------+
          
               +-----------------------------------------------------------------+
            3. | make          | price | mpg | rep78 | headroom | trunk | weight |
               | AMC Spirit    | 3,799 |  22 |     . |      3.0 |    12 |  2,640 |
               |-----------------------------------------------------------------|
               |  length   |  turn   |  displa~t   |   gear_r~o   |    foreign   |
               |     168   |    35   |       121   |       3.08   |   Domestic   |
               +-----------------------------------------------------------------+
          
               +-----------------------------------------------------------------+
            4. | make          | price | mpg | rep78 | headroom | trunk | weight |
               | Buick Century | 4,816 |  20 |     3 |      4.5 |    16 |  3,250 |
               |-----------------------------------------------------------------|
               |  length   |  turn   |  displa~t   |   gear_r~o   |    foreign   |
               |     196   |    40   |       196   |       2.93   |   Domestic   |
               +-----------------------------------------------------------------+
          
               +-----------------------------------------------------------------+
            5. | make          | price | mpg | rep78 | headroom | trunk | weight |
               | Buick Electra | 7,827 |  15 |     4 |      4.0 |    20 |  4,080 |
               |-----------------------------------------------------------------|
               |  length   |  turn   |  displa~t   |   gear_r~o   |    foreign   |
               |     222   |    43   |       350   |       2.41   |   Domestic   |
               +-----------------------------------------------------------------+
          
<pre class="sh_stata">  . histogram price</pre>
          (bin=8, start=3291, width=1576.875)
          
          
<pre class="sh_stata">  . graph export graph.png, replace width(350)</pre>
          (file graph.png written in PNG format)
          
          
Adding a graph using Markdown
-----------------------------

In order to add a graph using Markdown, I export the graph in PNG format.
You can explain the graph in the brackets and define the file path in
parentheses using Markdown syntax. Note that Markdown format cannot resize the
figure and it will include it at its full size. Therefore, when you write with
Markdown you should resize the graphs. Of course, if you write with _LaTeX_ or
_HTML_ you will be able to do anything you wish! But _Markdown_ is convertable
to any format and thus is the prefered markup language for writing dynamic
documents. In addition, it is a very minimalistic language. And perhaps that's
what makes it so good, because it does not include numerous rules and tags to
learn, compared to _HTML_ and _LaTeX_. It's simple, easy to learn, and appealing
to use.

![](./graph.png)


Writing Dynamic Text
--------------------

The __txt__ command can be used to write dynamic text in MarkDoc.
To do so, put the value that you want to print in a Macro and then
explain it using the __txt__ command. Or instead, I use the stored values
that Stata returns after particular commands by typinc __return list__.

In the example below, I use the summarize command, and print the r(N), r(mean),
r(sd), r(min), and r(max) which are returned after the __summarize__ command.
          
<pre class="sh_stata">  .  summarize price </pre>
          
              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
                 price |         74    6165.257    2949.496       3291      15906
          
          
          
The dataset used for this analysis includes 74 observations for                 the __price__ variable, with mean of 6
165.256756756757 and SD of 2949.495884768919. The                   price of cars' ranged from 3291 to 15906.
<pre class="sh_stata">  .  regress price mpg</pre>
          
                Source |       SS           df       MS      Number of obs   =        74
          -------------+----------------------------------   F(1, 72)        =     20.26
                 Model |   139449474         1   139449474   Prob > F        =    0.0000
              Residual |   495615923        72  6883554.48   R-squared       =    0.2196
          -------------+----------------------------------   Adj R-squared   =    0.2087
                 Total |   635065396        73  8699525.97   Root MSE        =    2623.7
          
          ------------------------------------------------------------------------------
                 price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
          -------------+----------------------------------------------------------------
                   mpg |  -238.8943   53.07669    -4.50   0.000    -344.7008   -133.0879
                 _cons |   11253.06   1170.813     9.61   0.000     8919.088    13587.03
          ------------------------------------------------------------------------------
          
          
          
[You will find more information in this regard on my website](http://haghish.com/).
You can also [Follow The Package Updates On TWITTER!](http://twitter.com/Haghish)


E. F. Haghish
Center for Medical Biometry and Medical Informatics
University of Freiburg, Germany
_haghish@imbi.uni-freiburg.de_

          
          
</body>
</html>
