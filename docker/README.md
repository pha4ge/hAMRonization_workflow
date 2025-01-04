# Docker

This directory has scripts to (locally) build and test the Docker container.

## Building

The `build-containers.sh` script successively builds 4 images:

 * step 0: base Conda with only Snakemake added (= `envs/hamronization_workflow.yaml`)
 * step 1: step 0 with on top all tools, installed by Snakemake (= `envs/*.yaml`)
 * step 2: step 1 with on top the binary deps (minor step)
 * step 3: step 2 with on top the databases (massive final step)

The images all have the same Dockerfile, except that an additional RUN step
is added in each.  This so that if the build fails at some step, we have the
successful image from the prior step for debugging the failing step.

> We could have also used Docker's `FROM ...` to do this, but the idea is that
> once the build is stable, we can ditch the steps and just have `Dockerfile`
> (i.e. the final image).
>
> OTOH, as long as the Dockerfiles are identical up to the penultimate step,
> they share all their image layers, so none of the earlier steps consume any
> disc space or build time.

## Running

The `run-*.sh` scripts are convenience wrappers for `docker run ...`, with
the necessary mounts set up.

## Testing

The `test-final.sh` script runs the final container against the test data
in `../test`, writing results and logs to `/tmp`.

