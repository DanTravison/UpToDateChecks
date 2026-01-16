This project illustrates the problem where setting the 'Up-to-date Checks' setting
causes the build to not consider the Inputs for custom build targets in the project file.

The purpose is to 'publish' a set of files to an external publish directory (Outside the soltion)
and generate a JSON file that serves as a manifest for selected files with a LastModified
property for each file. An input JSON file indicates which files should be included
in the manifest.

The Example.csproj has two custom build targets, PublishAssets and PublishMeta.

Both Targets have a Condition that the $PublishDir must exist.

## PublishAssets: 
- Copies asset files to a publish directory outside the solution
- The inputs are Assets\*.txt
- The Outputs are the same files in the $PublishDir

The Target is expected to run if any changes occur to the Assets\*.txt files
or the output files do not exist.

## PublisMeta: 
Reads the Assets\meta.json and produces a $(PublishDir)\meta.json.
NOTE: A Condition on the existance of the $PubishDir ensures the script is only
run on the build system.

The Target is expected to be run if any of the following files changed (Inputs)
- The asset files (Assets\*.txt)
- The input meta file (Assets\meta.json)
- The script itself (Build\Generate-Meta.ps1)
- The output file ($PublishDir\meta.json) does not exist.
 
## Problem Description/Repro
- Open the Example.sln in the Example folder
- Set logging level for Up-to-date Checks to at least 'Info' for the repro.

When the 'Up-to-date Checks' setting is enabled, changes to the inputs for
any of the targets does not result in the target executing.

For example:
- Change the last modified of a Assets\*.txt 
- Change the last modified of Assets\meta.json
- Change the last modified of Build\Generate-Meta.ps1
- Delete the contents of the $PublishDir

In contrast, disabling 'Up-to-date Checks' causes the biuld targets to run as expected.

For example:
- Change the last modified of a txt file under Assets
  - PublishAssets runs
  - PublishMeta runs

- Change the last modified of Assets\meta.json
 - PublishMeta runs

 - Change the last modified of Build\Generate-Meta.json
  - PublishMeta runs

- Delete the contents of the $PublishDir
  - PublishAssets runs
  - PublishMeta runs


