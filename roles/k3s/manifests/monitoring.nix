{
  config,
  pkgs,
  ...
}: {
  systemd.services.k3s-monitoring = {
    description = "Deploy Prometheus, Grafana and Loki";
    after = ["k3s.service" "sops-nix.service"];
    wants = ["k3s.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
    };
    script = ''
      until ${pkgs.kubectl}/bin/kubectl get nodes; do sleep 2; done

      # Add helm repos
      ${pkgs.kubernetes-helm}/bin/helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      ${pkgs.kubernetes-helm}/bin/helm repo add grafana https://grafana.github.io/helm-charts
      ${pkgs.kubernetes-helm}/bin/helm repo update

      # Install kube-prometheus-stack
      ${pkgs.kubernetes-helm}/bin/helm upgrade --install kube-prometheus-stack \
        prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=$(cat ${config.sops.secrets."grafana-password".path}) \
        --set grafana.ingress.enabled=true \
        --set grafana.ingress.ingressClassName=nginx \
        --set "grafana.ingress.annotations.cert-manager\.io/cluster-issuer=letsencrypt-prod" \
        --set grafana.ingress.hosts[0]=grafana.krugten.org \
        --set grafana.ingress.tls[0].secretName=grafana-tls \
        --set "grafana.ingress.tls[0].hosts[0]=grafana.krugten.org" \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=local-path \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
        --set grafana.persistence.enabled=true \
        --set grafana.persistence.storageClassName=local-path \
        --set grafana.persistence.size=1Gi \
        --timeout 10m \
        --wait

      # Install Loki for logs
      ${pkgs.kubernetes-helm}/bin/helm upgrade --install loki \
        grafana/loki-stack \
        --namespace monitoring \
        --set grafana.enabled=false \
        --set prometheus.enabled=false \
        --timeout 10m \
        --wait
    '';
  };
}
