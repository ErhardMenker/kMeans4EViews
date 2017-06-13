# K-means clustering EViews add-in

- This repository contains the add-in used to implement k-means clustering in EViews
- The implementation is heavily sourced from the k-means lectures in Andrew Ng's Stanford machine learning Coursera course (https://www.coursera.org/learn/machine-learning/lecture/93VPG/k-means-algorithm)

## Core folders/files:

- ./kmeans.prg is the EViews program that executes the k-means clustering routine
- ./unit_tests is a folder containing programs that call the file to test scalability/accuracy


## Installing k-means add-in

- Git users: clone the repo to your local machine & run ./installers/kmeans.aipz
- Non-Git users: click the "view raw" link at: https://github.com/ErhardMenker/kMeans4EViews/blob/master/Installers/kmeans.aipz
- Click yes to all the buttons - k-means add-in is now installed!
- Open up the docs in your add-in manager to see an application & documentation