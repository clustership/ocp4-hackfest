# Deploy sandboxed container operator (kata containers) on OpenShift 4.8

## Create secret to access qe registry

First of all, you need to add credentials to access the qe quay registry to pull the operator's containers.

Grab qe-registry.auth.json from here: https://docs.google.com/document/d/1hGb2B9IYLAlyD2Y-RiuUu5ZvrGZ_qtKEUsYGInPSlEo/edit?usp=sharing
and paste it in a file called qe-registry-auth.json

To preserve the original pull-secret for Red Hat registries, we merge the content of the current secret with these new information.

```bash
oc -n openshift-config get secret pull-secret -o jsonpath='{.data.\.dockerconfigjson}' \
  | base64 -d \
  | jq . \
  > pull-secret-orig.json
jq -s '.[0] * .[1]' pull-secret-orig.json qe-registry-auth.json > pull-secret-all.json
oc set data secret/pull-secret --from-file=.dockerconfigjson=pull-secret-all.json -n openshift-config
```

## Add ImageContentSourcePolicy

Create an ImageContentSourcePolicy to define the additional qe repositories.

```bash
cat <<EOF  | oc create -f -
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
 name: brew-registry
spec:
 repositoryDigestMirrors:
 - mirrors:
   - brew.registry.redhat.io
   source: registry.redhat.io
 - mirrors:
   - brew.registry.redhat.io
   source: registry.stage.redhat.io
 - mirrors:
   - brew.registry.redhat.io
   source: registry-proxy.engineering.redhat.com
EOF
```

## Configure catalogsource

```bash
echo "#Create CatalogSource from $IIB"
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
 name:  qe-optional-operators
 namespace: openshift-marketplace
spec:
 sourceType: grpc
 image: quay.io/openshift-qe-optional-operators/ocp4-index:latest
EOF
```


## Check operator

Check the operator is deployed and running.

```bash
oc get pods -n openshift-marketplace |egrep qe-
qe-optional-operators-lztbf             1/1     Running   0          7m7s

oc -n openshift-marketplace get packagemanifests | egrep sandbox
sandboxed-containers-operator                                              10m

oc -n openshift-marketplace describe packagemanifests sandboxed-containers-operator | less

```

## Wait for MachineConfig to apply on selected nodes

Wait while worker nodes are in NotReady or SchedulingDisabled state for the operator to apply the new configuration on nodes.

```bash
watch oc get nodes
```

## Create the Kataconfig object

```bash
cat <<EOF | oc apply -f -
apiVersion: kataconfiguration.openshift.io/v1
kind: KataConfig
metadata:
  name: default-kataconfig
```

# Validation

## Launch pod

```bash
oc --dry-run=client create deployment kata-deploy --image=quay.io/xymox/ubi8-debug-toolkit:0.2 -o yaml \
  | yq e '.spec.template.spec.runtimeClassName = "kata"' - \
  | yq e '.spec.replicas = 3' - \
  | oc apply -f -
```
