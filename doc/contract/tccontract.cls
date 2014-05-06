% -*- latex -*-
%
% A basic class for handling contracts
%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tccontract}

\usepackage{times}
\usepackage{multicol}

\setlength{\textwidth}{6in}
\setlength{\oddsidemargin}{0in}
\setlength{\evensidemargin}{0in}

\setlength{\textwidth}{6.5in}
\setlength{\textheight}{8in}
\setlength{\parindent}{1em}
\setlength{\parskip}{1ex \@plus .3ex}

\newcommand\scriptsize{\@setfontsize\scriptsize\@vipt\@viipt}
\newcommand\tiny{\@setfontsize\tiny\@vipt\@viipt}
\renewcommand\normalsize{\@setfontsize\normalsize\@ixpt\@xipt}
\newcommand\large{\@setfontsize\large\@ixpt\@xipt}
\newcommand\Large{\@setfontsize\Large\@xpt\@xiipt}
\newcommand\LARGE{\@setfontsize\LARGE\@xipt\@xiiipt}
\newcommand\huge{\@setfontsize\huge\@xiipt{15pt}}
\newcommand\Huge{\@setfontsize\Huge\@xxvpt{30pt}}


\setlength{\footskip}{.5in}
\def\ps@plain{%
      \let\@oddhead\@empty
      \def\@oddfoot{\normalfont\hfil\thepage\ of \pageref{THEEND}\hfil}%
      \def\@evenfoot{\normalfont\hfil\thepage\ of \pageref{THEEND}\hfil}}
\pagenumbering{arabic}
\pagestyle{plain}
%
% A clause is a run-in paragraph, numbered
%

\newcounter{CLAUSE}
\newcommand{\clause}[1]{\par\vskip .5in\penalty -20\vskip -.35in%
  \refstepcounter{CLAUSE}%
  \noindent\textbf{\textsc{\large \theCLAUSE.\ #1.}}\quad\relax}

%
% The standard header
%
% Use as:
%   \begin{header}{Consultancy Services Agreement}
%      <text>  or  \stdhead{name}{date}
%   \end{header}

\newenvironment{header}[1]
{{\leavevmode\noindent\normalsize\par
  \hrule height 2pt
  \vskip 2pt
  \hrule height .5pt
  \vskip 1em
  \begin{centering}
    {\Huge #1}\\
  \end{centering}
  \vskip 4pt
  \hrule height .5pt
  \vskip 2pt
  \hrule height 2pt
  \vskip 2\baselineskip
  }\par\Large
  }%
{\par}
  
\newcommand{\stdhead}[2]{This agreement is entered into on #2 between
  #1 (the Client), and Thomas Consulting of Dallas,
  Texas (the Consultant).  The parties agree that this document is
  the entire agreement under which services are provided by the
  Consultant for the Client.
}

%
% The body of the contract is in two columns
%

\newenvironment{body}{%
  \setlength{\columnseprule}{.5pt}
  \setlength{\columnsep}{2em}
  \begin{multicols}{2}\raggedright\normalsize
    \setlength{\parindent}{2em}%
}{%
  \end{multicols}
}

%
% A signature block  \sign{their name}
%

\newcommand{\sign}[2]{%
  \newcommand{\@line}{\rule[-.1\baselineskip]{2.5in}{.5pt}}%
  \par
  \textsc{In witness whereof,} the parties hereto, by their respective
  duly authorized officers or representatives have each executed this
  Agreement, effective as of the date first above written.\\[2em]

  \label{THEEND}
  \begin{multicols}{2}\raggedright\normalsize
    \setlength{\columnseprule}{0pt}%
    \setlength{\columnsep}{2em}%
    \setlength{\parindent}{2em}%
\noindent    \textbf{Thomas Consulting}\mbox{}\\[2em]
    \begin{tabbing}
      \emph{signed:\ } \=\kill
      \emph{by:}    \> \textbf{#2} \\[2em]
      \emph{title:} \> Owner      \\[4em]
      \emph{signed:}\> \@line \\
    \end{tabbing}
\noindent    \textbf{#1}\mbox{}\\[2em]
    \begin{tabbing}
      \emph{signed:\ } \=\kill
      \emph{by:}    \> \@line \\[2em]
      \emph{title:} \> \@line \\[4em]
      \emph{signed:}\> \@line \\
    \end{tabbing}
  \end{multicols}%
}

%
% DAVE: Forgive me, for the hour is late...
%
\newcommand{\shortsign}[2]{%
  \newcommand{\@line}{\rule[-.1\baselineskip]{2.5in}{.5pt}}%
  \par
  \textsc{In witness whereof,} the parties hereto, by their respective
  duly authorized officers or representatives have each executed this
  Agreement, effective as of the date first above written.\\[2em]

  \label{THEEND}
  \begin{multicols}{2}\raggedright\normalsize
    \setlength{\columnseprule}{0pt}%
    \setlength{\columnsep}{2em}%
    \setlength{\parindent}{2em}%
\noindent    \textbf{Thomas Consulting}\mbox{}\\[1em]
    \begin{tabbing}
      \emph{signed:\ } \=\kill
      \emph{by:}    \> \textbf{#2} \\[1em]
      \emph{title:} \> Owner      \\[1em]
      \emph{signed:}\> \@line \\
    \end{tabbing}
\noindent    \textbf{#1}\mbox{}\\[1em]
    \begin{tabbing}
      \emph{signed:\ } \=\kill
      \emph{by:}    \> \@line \\[1em]
      \emph{title:} \> \@line \\[1em]
      \emph{signed:}\> \@line \\
    \end{tabbing}
  \end{multicols}%
}


%
% This is all the list crap that individual sty;es must set
%


\setlength{\leftmargini}{10pt}
\setlength{\leftmarginii}{8pt}
\setlength{\leftmarginiii}{8pt}
\setlength{\leftmarginiv}{8pt}
\setlength{\leftmarginv}{8pt}
\setlength{\leftmarginvi}{8pt}

\typeout{left = \the\leftmargini  text = \the\textwidth}
\setlength\labelsep      {4pt}

\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}

\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty

\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}

\newcommand\labelenumi{\theenumi.}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}

\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}

\newcommand\labelitemi{\textbullet}
\newcommand\labelitemii{\normalfont\bfseries \textendash}
\newcommand\labelitemiii{\textasteriskcentered}
\newcommand\labelitemiv{\textperiodcentered}

\def\@listi{\leftmargin\leftmargini
            \parsep 2\p@ \@plus1\p@ \@minus\p@
            \topsep 3\p@ \@plus1\p@ \@minus2\p@
            \itemsep4\p@ \@plus1\p@ \@minus\p@}

\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \topsep    1\p@ \@plus1\p@ \@minus\p@
              \parsep    1\p@ \@plus\p@  \@minus\p@
              \itemsep   \parsep}

\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \topsep    1\p@ \@plus\p@\@minus\p@
              \parsep    \z@
              \partopsep \p@ \@plus\z@ \@minus\p@
              \itemsep   \topsep}

\def\@listiv {\leftmargin\leftmarginiv
              \labelwidth\leftmarginiv
              \advance\labelwidth-\labelsep}

\def\@listv  {\leftmargin\leftmarginv
              \labelwidth\leftmarginv
              \advance\labelwidth-\labelsep}

\def\@listvi {\leftmargin\leftmarginvi
              \labelwidth\leftmarginvi
              \advance\labelwidth-\labelsep}

\@listi
% LocalWords:  Toolshed LISTI
