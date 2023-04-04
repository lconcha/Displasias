# ratCortex-dMRIstreams

Code to process dMRI volumes and create cortical streamlines in rat data. 

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
