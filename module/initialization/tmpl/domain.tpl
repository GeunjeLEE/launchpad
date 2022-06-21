enabled: true
image:
    name: spaceone/spacectl
    version: 1.9.7.3
main:
  import:
    - /root/spacectl/apply/root_domain.yaml 
    - /root/spacectl/apply/marketplace.yaml
    - /root/spacectl/apply/user_domain.yaml
    - /root/spacectl/apply/role.yaml
    - /root/spacectl/apply/statistics.yaml
  var:
    domain:
      root: root
      user: spaceone
    default_language: ko
    default_timezone: Asia/Seoul
    domain_owner:
      id: admin
      password: Admin123!@#
    user:
      id: root_api_key
    consul_server: spaceone-consul-server
    marketplace_endpoint: grpc://repository.portal.spaceone.dev:50051
    project_manager_policy_id: policy-managed-project-manager
    project_viewer_policy_id: policy-managed-project-viewer
    domain_admin_policy_id: policy-managed-domain-admin
    domain_viewer_policy_id: policy-managed-domain-viewer

  tasks: []
