# Considerations for running OpenShift Dev Spaces at Scale

## Managing Container Images

Consider creating a declarative and GitOps driven system to manage container images for your enterprise.

One of the major challenges of any organization is managing dependencies, versions, and CVEs in all of their runtimes - Dev/QA/Prod

A GitOps driven approach to managing container images can greatly reduce the toil that comes with wrangling all of the things running in the enterprise.

The open source project [CeKit](https://cekit.io) offers a declarative means to manage images.  

If you create a tree based approach, where runtime and developer images share common components, then you ensure consistency between Dev/QA/Prod environments.

```bash
Base-Image # my.org.registry/images/common-base:latest - Built from - registry.access.redhat.com/ubi9 + org specific dependencies
|
|-|- Runtime Java 21 # Base + Java 21 Module
  |
  |- Developer Tooling # Base + Java 21 Module + Maven Module + Developer Common Module
```

## Managing Workspaces

OpenShift Dev Spaces offers developers a ton of flexibility and freedom.  But, to fully leverage it a developer needs to think about their Dev Spaces workspaces in a totally different way from how they think about their local workstation today.

* __Workspaces should not be general purpose__
  * Workspaces are best thought about as project/produce specific.  The tooling and configuration in the workspace should be bespoke for a given code base or related set of code bases.  This approach will help reduce developer toil and cognitive load because they no longer have to think about switching out library version, tools, or collaborative services like middleware or databases.
  * Don't try to manage a kitchen sink developer tooling image...
  * Don't create a one-size-fits-nobody workspace image...
  * __Bespoke__ is your watchword.  Workspaces should be configured for development on a specific application ecosystem.
  * Please, for the love of all that is holy and good in this world...  Do not create user specific workspaces for project work.  User specific workspaces should only be used for one off prototyping or POC work.  See the next bullet down. 
* __Workspaces are *DISPOSABLE*__
  * From nothing to writing code should take less than two minutes with OpenShift Dev Spaces.  One of the worst things that a developer can do with Dev Spaces is to think of it like their local workstation.  Something that must be backed up, updated, customized, protected from harm...  A Dev Spaces workspace is created from configuration stored in a Git repository.  It is very important that developer teams think of their workspace configuration as they think of their code.  If I can recreate a given workspace in less than two minutes, then I don't need to hang on to my personal instance of the workspace indefinitely.  In fact, if I do try to hang on to it over long periods, then configuration drift can be introduced.
  * When a developer is done with a particular work assignment on a project for a while, they should delete the workspace knowing full well that they can get it back in a matter of seconds.

## Cluster Resource Management

* __No one like a noisy neighbor__
  * Implement resource limits and quotas
  * [Configuring User Namespaces](https://docs.redhat.com/en/documentation/red_hat_openshift_dev_spaces/3.18/html/administration_guide/configuring-devspaces#configuring-a-user-namespace)
* Take care of `etcd` in your cluster.
  * Etcd is the state management heart of your OpenShift cluster.  It is an extremely fast distributed data store.  But, when it gets clogged up with garbage...  it can and will impact the performance of your entire OpenShift cluster.
  * There are two things that you can do to be good custodians of `etcd` in your cluster.
    1. Implement a workspace pruner to remove unused workspaces from the cluster.  Remember... THEY ARE DISPOSABLE!  sorry...  really didn't mean to shout there...  ;-)
       
       [DevWorkspace Pruner](https://github.com/devfile/devworkspace-operator/issues/1376)

    1. Configure you cluster so that the Operator Lifecycle Manager does not copy Cluster Service Version objects into every managed namespace.
       
       [Disabling Copied CSVs](https://docs.openshift.com/container-platform/4.18/operators/admin/olm-config.html#olm-disabling-copied-csvs_olm-config)
* Use a `per-workspace` storage strategy instead of `per-user`
  * A `per-workspace` strategy will make more efficient use of storage because PVCs will be lifecycled with workspaces.  The trade-off will be the number of PVC created and destroyed.  Ensure that your storage provisioner can handle the expected load.

## Recovering from Disaster

Did I mention that Dev Spaces workspaces are disposable?

[Short Video on Dev Spaces Resiliency](https://www.youtube.com/watch?v=A0Stdf8wTXA)

The best strategy for continuity of service with OpenShift Dev Spaces is to have a secondary cluster that is ready to take on developer load.

The main considerations -

* Have one or more mirrors of your SCM
  
  Your life is your code.  Make sure that your Git SCM is mirrored to other regions.

* Ensure that all workspace configuration is stored with your code in the SCM

* Provision, or allocate an OpenShift cluster to take on developer workspace load

  Ensure that global Dev Spaces configuration is implemented across multiple clusters

When the primary developer cluster gets sick, or is inaccessible, all a developer has to do is log into an alternate cluster and recreate their workspaces from the SCM.