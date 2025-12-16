

```bash
# For Control-Plane nodes -
# MACHINE_TYPE=master

# For Compute Nodes
# MACHINE_TYPE=worker

MACHINE_TYPE=worker

cat << EOF | butane | oc apply -f -
variant: openshift
version: 4.20.0
metadata:
  labels:
    machineconfiguration.openshift.io/role: ${MACHINE_TYPE}
  name: selinux-patch-${MACHINE_TYPE}
storage:
  files:
  - path: /etc/selinux_patch/selinux_patch.te
    mode: 0644
    overwrite: true
    contents:
      inline: |
        module selinux_patch 1.0;

        require {
                type tun_tap_device_t;
                type container_engine_t;
                class chr_file { getattr ioctl open read write };
        }

        #============= container_engine_t ==============
        allow container_engine_t tun_tap_device_t:chr_file { getattr open read write ioctl };
systemd:
  units:
  - contents: |
      [Unit]
      Description=Modify SeLinux Type container_engine_t
      DefaultDependencies=no
      After=kubelet.service

      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=bash -c "/bin/checkmodule -M -m -o /tmp/selinux_patch.mod /etc/selinux_patch/selinux_patch.te && /bin/semodule_package -o /tmp/selinux_patch.pp -m /tmp/selinux_patch.mod && /sbin/semodule -i /tmp/selinux_patch.pp"
      TimeoutSec=0

      [Install]
      WantedBy=multi-user.target
    enabled: true
    name: systemd-selinux-patch-selinux.service
EOF
```