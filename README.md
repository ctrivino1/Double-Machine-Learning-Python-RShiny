# RShiny App for Causal Analysis with Double Machine Learning

This RShiny application is designed to help teach students and data scientists about causal analysis using Double Machine Learning (DML). This method is based on the Research paper '[Double/Debiased Machine Learning for Treatment and Causal Parameters](https://arxiv.org/abs/1608.00060)' by Victor Chernozhukov, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. 

### Project Status
This project is currently ongoing and is being actively developed. While the DML Causal Analysis Tool is functional and available for exploration, I am  working to enhance its features and functionality.

Feel free to explore the tool and provide feedback or suggestions for improvement. Your input is valuable in shaping the future direction of this project.

Thank you for your interest and support!
[Launch the DML Causal Analysis Tool](https://big-cat.shinyapps.io/DML_Causal_Analyisis_Tool/)

# Educational Features
<details>
  <summary>Click to expand</summary>
### RShiny App Development

-   **Modularizing RShiny apps**: Understand how to modularize an RShiny app using files for better organization, especially for large RShiny projects.
-   **Using Reactive Functions**: Explore how to use reactive functions effectively and save reactive variables for subsequent calculations.
-   **Embedding Google Slides**: Learn how to incorporate Google Slides into your RShiny app, allowing users to view slides seamlessly.
-   **Using Slidy Presentation in RMD Files**: Learn how to utilize the `slidy_presentation` option for RMD files and customize the output using CSS code, as explained in the notes section of the `.Rmd` file.

### Integration of Python Scripts in RShiny

-   **Integrating Python Scripts within R/Rshiny**: Learn how to integrate Python scripts within RShiny and convert Pandas dataframes back to R data frames seamlessly. If you use my created dml.py function, a citation is highly appreciated: [Citation](#citation).
-   **Setting Up Virtual Python Environment**: Understand how to set up a virtual Python environment within RShiny using the `.Rprofile` file.

### Modularization and Organization

-   **Incorporating Objects from a www File**: Discover how to incorporate objects from a `www` file into your app, as instructed at the bottom of the `dml_ui.R` file located in the `tabs` folder.
-   **Sourcing Code from other files**: Understand how to source code from other files, enabling values saved in one file to be used in another.

### Advanced UI Customization

-   **Incorporating Custom HTML Objects**: Understand how to include custom HTML objects rendered from an .Rmd file directly into your RShiny app.
-   **Incorporating CSS for Customized UI Options**: Explore how to incorporate CSS for customized UI options, enhancing the visual appeal of your RShiny app. The CSS code is in a variable called 'css_body' in the `dml_ui.R` file.
-   **Incorporating JavaScript Code for Custom RShiny Functionality**: Learn how to incorporate JavaScript code into your RShiny app for additional functionality and interactivity. The JS code is in a variable called 'JS_body' in the `dml_ui.R` file. The JS code in this file allows the minimize button of a box() section to work.

### Version Control and Collaboration

-   **Version Control and Collaboration**: Practice version control techniques using Git and GitHub. Collaborate with peers on app development, share code, and review pull requests.

### Research and Citation Practices

-   **Research and Citation Practices**: Understand the importance of citing relevant literature and research papers in academic projects. Learn how to properly cite sources and give credit to original authors.

### Data Science Best Practices

-   **Data Science Best Practices**: Gain exposure to best practices in data preprocessing, analysis, and interpretation. Learn how to validate and interpret causal inference results in real-world scenarios.
</details>

<a name="citation"></a>
# Citation 
Please, if you use the `dml.py` file in your project, I kindly request that you cite my work with the following:

BibTeX entry:

```bibtex
@misc{Trivino2024,
  title   = {Rshiny Implementation of Double Machine Learning with Python},
  author  = {Trivino, Christopher},
  year    = {2024},
  url     = {https://github.com/DoubleML/doubleml-for-py.git}
}
```


# Acknowledgments
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

