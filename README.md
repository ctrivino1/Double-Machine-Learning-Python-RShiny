
# RShiny App for Causal Analysis with Double Machine Learning

This RShiny application is designed to help teach students and data scientists about causal analysis using Double Machine Learning (DML). This method is based on the Research paper '[Double/Debiased Machine Learning for Treatment and Causal Parameters](https://arxiv.org/abs/1608.00060)' by Victor Chernozhukov, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. 

In addition to learning about causal analysis, users can also gain advanced knowledge of Rshiny in the following areas:

## Integrating Python Scripts within R/Rshiny

Learn how to integrate Python scripts within RShiny and convert Pandas dataframes back to R data framess seamlessly. (If you use my created dml.py file  a citation is highly appreciated: [Citation](#citation))

## Modularizing RShiny Tabs

Understand how to modularize an RShiny app using files for better organization, espeically for large Rshiny projects.

## Using Reactive Function

Explore how to use reactive functions effectively and save reactive variables for subsequent calculations.

## Incorporating Google Slides

Learn how to incorporate Google Slides into your RShiny app, allowing users to view slides seamlessly.

## Including Custom HTML Objects

Understand how to include custom HTML objects rendered from an .Rmd file directly into your RShiny app.

## Incorporating Objects from a www File

Discover how to incorporate objects from a `www` file into your app, as instructed at the bottom of the `dml_ui.R` file located in the `tabs` folder.

## Using Slidy Presentation in RMD Files

Learn how to utilize the `slidy_presentation` option for RMD files and customize the output using CSS code, as explained in the notes section of the `.Rmd` file.

## Setting Up Virtual Python Environment

Understand how to set up a virtual Python environment within RShiny using the `.Rprofile` file.

## Incorporating CSS for Customized UI Options

Explore how to incorporate CSS for customized UI options, enhancing the visual appeal of your RShiny app.The CSS code is in a variable called 'css_body' in the  `dml_ui.R` file.

## Incorporating JavaScript Code

Learn how to incorporate JavaScript code into your RShiny app for additional functionality and interactivity.The CSS code is in a variable called 'JS_body' in the  `dml_ui.R` file.

## Sourcing Code from Other Files

Understand how to source code from other files, enabling values saved in one file to be used in another.

By exploring these features and functionalities, users can gain a comprehensive understanding of causal analysis with Double Machine Learning while also enhancing their skills in various aspects of RShiny app development.

<a name="citation"></a>
## Citation 
Please, if you use the `dml.py` file in your project, I kindly request that you cite my work with the following:

BibTeX entry:

```bibtex
@misc{Trivino2024,
  title   = {[Implementation of Double Machine Learning Algorithm in Python for Integration with RShiny]},
  author  = {Trivino, Christopher},
  year    = {2024},
  url     = {[URL of Your GitHub Repository or Project Page](https://github.com/ctrivino1/DML_Rshiny_App.git)]}
}
```


## Acknowledgments
I would like to acknowledge the creators of the DoubleML package for their valuable contribution to this project. They have asked anyone using their package to use this citation:

Bach, P., Chernozhukov, V., Kurz, M. S., and Spindler, M. (2022), DoubleML - An Object-Oriented Implementation of Double Machine Learning in Python, Journal of Machine Learning Research, 23(53): 1-6, [Link to Paper](https://www.jmlr.org/papers/v23/21-0862.html).

BibTeX entry:

```bibtex
@article{DoubleML2022,
      title   = {{DoubleML} -- {A}n Object-Oriented Implementation of Double Machine Learning in {P}ython}, 
      author  = {Philipp Bach and Victor Chernozhukov and Malte S. Kurz and Martin Spindler},
      journal = {Journal of Machine Learning Research},
      year    = {2022},
      volume  = {23},
      number  = {53},
      pages   = {1--6},
      url     = {http://jmlr.org/papers/v23/21-0862.html}
}

