ActiveAdmin.register Vulnerability do
  menu priority: 0, label: 'Vulnerabilities', parent: 'Vulnerabilities'

  actions :all, except: [:new]

  filter :os, as: :select, collection: proc { Vulnerability.pluck(:os).uniq.compact }
  filter :severity, as: :select, collection: proc { Vulnerability.pluck(:severity).uniq.compact }
  filter :ip_address

  index do
    selectable_column
    id_column
    column :severity
    column :name do |v|
      link_to v.name.truncate(50, seperator: ' '), admin_vulnerability_path(v)
    end
    column :ip_address
    column :target_tag
    column :os
    column :discovered_date
    column 'Technician', :admin_user
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :severity
      row :ip_address
      row :os
      row :discovered_date
      row :last_scanned_date
      row 'Technician', :admin_user
      row :description
      row :solution
      # Add more fields as needed
    end

    # Section for associated Vulnerability Updates
    panel "Status Updates" do
      table_for vulnerability.vulnerability_updates.order(id: :desc) do
        column :scan do |vupdate|
          link_to vupdate.vulnerability_scan.name, admin_vulnerability_scan_path(vupdate.vulnerability_scan.id)
        end
        column :update_type
        column :created_at
      end
    end

    # Section for associated Vulnerability Scans
    panel "Associated Vulnerability Scans" do
      table_for vulnerability.vulnerability_scans.order(id: :desc) do
        column :id do |vscan|
          link_to vscan.id, admin_vulnerability_scan_path(vscan)
        end
        column :name
        column :created_at
        column :updated_at
      end
    end

    active_admin_comments
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :os, :description, :severity, :ip_address, :admin_user_id
  permit_params :os, :object_hash, :name, :cve_id, :target, :service, :evidence, :severity, :solution, :scan_name, :cvss_score, :ip_address, :pci_status, :target_tag, :description, :host_status, :project_name, :discovered_date, :last_scanned_date, :service_description, :approved_false_positive_evidence, :vulnerability_scan_id, :admin_user_id

  #
  # or
  #
  # permit_params do
  #   permitted = [:os, :description, :severity, :ip_address]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # show do
  #   # h3 vulnerability.title
  #   panel 'Details' do
  #     attributes_table_for vulnerability do
  #       row :description
  #       row :technician do |r|
  #         r.admin_user.email
  #       end
  #     end
  #   end
  # end

  # sidebar :updates, only: :show do
  #   # attributes_table_for vulnerability do
  #   #   row :os
  #   #   row :severity
  #   #   row :ip_address
  #   # end

  #   # Section for associated Vulnerability Updates
  #   table_for vulnerability.vulnerability_updates do
  #     column :scan do |vupdate|
  #       link_to vupdate.vulnerability_scan.name, admin_vulnerability_scan_path(vupdate.vulnerability_scan.id)
  #     end
  #     column :update_type
  #   end
  # end

end
