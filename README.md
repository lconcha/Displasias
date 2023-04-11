# ratCortex-dMRIstreams

Code to process dMRI volumes and create cortical streamlines in rat data. 

This repository contains scripts and functions necessary to work with the data in the rat dysplasia project and published for transparency purposes. It is not intended for use with other data, as many things are hard-coded.

Code by:
* David Cortés-Servín
* Aylín Pérez-Moriel
* Fernando Palazuelos
* Luis Concha

Institute of Neurobiology, UNAM; Centro de Investigación en Matemáticas, A.C.



## Setup

1. Install the [MINC](https://en.wikibooks.org/wiki/MINC) tools required for the code:
    ```bash
    sudo apt install minc-tools
    ```

2. Create a conda environment:
    ```bash
    conda env create --file environment.yml
    ```

3. Activate the environment:
    ```bash
    conda activate cx-streams-env
    ```

4. Display script help:
    ```bash
    nii2streams.sh -h
    ```
