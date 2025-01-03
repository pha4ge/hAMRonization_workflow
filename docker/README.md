# Docker builds

The `build-containers.sh` script successively builds 4 images:

 * step 0: base Conda with only Snakemake added (= `envs/hamronization_workflow.yaml`)
 * step 1: step 0 with on top all tools, installed by Snakemake (= `envs/*.yaml`)
 * step 2: step 1 with on top the binary deps (minor step)
 * step 3: step 2 with on top the databases (massive final step)

The images all have the same Dockerfile, except that an additional RUN step
is added in each.  This so that if the build fails at some step, we have the
successful image from the prior step for debugging the next.

We could have also used Docker's `FROM ...` to do this, but the idea is that
once the build is stable, we ditch the steps and just have `Dockerfile`.

Note that since the Dockerfiles are cumulative, the images all share their
layers, so steps 0-2 all come for free in terms of build time and disc space.

