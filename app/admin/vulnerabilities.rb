ActiveAdmin.register Vulnerability do
  menu priority: 0, label: 'Vulnerabilities', parent: 'Vulnerabilities'

  actions :all, except: [:new, :destroy]

  scope :active, default: true, show_count: true do |vulnerabilities|
    vulnerabilities.where.not(status: ['stale', 'ignored', 'on_hold', 'resolved'])
  end

  scope :unassigned, show_count: true do |vulnerabilities|
    vulnerabilities.where.not(status: ['stale', 'ignored', 'on_hold', 'resolved']).where(admin_user: nil)
  end

  scope :assigned_to_me, show_count: true do |vulnerabilities|
    vulnerabilities.where(admin_user_id: current_admin_user.id).where.not(status: ['stale', 'resolved'])
  end

  scope :inactive, show_count: true do |vulnerabilities|
    vulnerabilities.where(status: ['stale', 'ignored', 'on_hold', 'resolved'])
  end

  filter :name
  filter :os, as: :select, collection: proc { Vulnerability.pluck(:os).uniq.compact }
  filter :severity, as: :select, collection: proc { Vulnerability.pluck(:severity).uniq.compact }
  filter :pci_status, as: :select, collection: proc { Vulnerability.pluck(:pci_status).uniq.compact }
  filter :ip_address
  filter :target_tag
  filter :status, as: :select, collection: proc { Vulnerability.statuses.map { |key, value| [key.humanize, value] } }, label: 'Status'
  filter :admin_user, as: :select, collection: proc { AdminUser.pluck(:name, :id) }, label: 'Technician'

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :admin_user, label: 'Technician'
      f.input :status, as: :select, collection: Vulnerability.statuses.keys.map { |s| [s.humanize, s] }
    end
    actions
  end

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
    column :pci_status
    column :discovered_date
    column 'Technician', :admin_user
    column :status do |vulnerability|
      vulnerability.status.humanize
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :cve_id do |vulnerability|
        if vulnerability.cve_id.present?
          safe_join(
            vulnerability.cve_id.split(',').map do |cve|
              link_to cve.strip, "https://nvd.nist.gov/vuln/detail/#{cve.strip}", target: "_blank"
            end,
            ', '
          )
        end
      end
      row :evidence
      row :description
      row :solution
      # Add more fields as needed
    end

    # Section for associated Vulnerability Updates
    panel "Scan Updates" do
      table_for vulnerability.vulnerability_updates.order(id: :desc) do
        column :scan do |vupdate|
          link_to vupdate.vulnerability_scan.name, admin_vulnerability_scan_path(vupdate.vulnerability_scan.id)
        end
        column 'Update', :update_type
        column :created_at
      end
    end

    # Section for associated Vulnerability Scans
    panel "Associated Vulnerability Scans" do
      table_for vulnerability.vulnerability_scans.order(id: :desc) do
        column :name do |vscan|
          link_to vscan.name, admin_vulnerability_scan_path(vscan)
        end
        column :update do |vscan|
          vulnerability.vulnerability_updates.where(vulnerability_scan: vscan).order(created_at: :desc).limit(1).pluck(:update_type).first || nil
        end
        column :created_at
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
  permit_params :os, :object_hash, :name, :cve_id, :target, :service, :evidence, :severity, :solution, :scan_name, :cvss_score, :ip_address, :pci_status, :target_tag, :description, :host_status, :project_name, :discovered_date, :last_scanned_date, :service_description, :approved_false_positive_evidence, :vulnerability_scan_id, :admin_user_id, :status

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

  sidebar :tracking, only: :show do
    attributes_table_for vulnerability do
      row 'Technician' do
        if vulnerability.admin_user
          link_to vulnerability.admin_user&.name, admin_admin_user_path(vulnerability.admin_user)
        end
      end
      row :status do |vulnerability|
        vulnerability.status.humanize
      end
      row :severity
      row :os
      row :target
      row :target_tag
      row :ip_address
      row :service
      # row :scan_name
      # row :project_name
      row :cvss_score
      row :pci_status
      row :host_status
      row :id
      row :object_hash
      row :discovered_date
      row :last_scanned_date
    end
  end


  # Batch actions
  batch_action :assign_technician, form: -> {
    # Define form fields for batch action
    { admin_user_id: AdminUser.pluck(:name, :id).prepend(["Unassigned", ""]) }
  } do |ids, inputs|
    # Assign the selected admin user to the selected vulnerabilities
    Vulnerability.where(id: ids).update_all(admin_user_id: inputs[:admin_user_id])
    redirect_to collection_path, notice: "Admin user has been assigned to selected vulnerabilities."
  end

  batch_action :change_status, form: -> {
    # Define form fields for batch action
    { status: Vulnerability.statuses.map { |key, value| [key.humanize, value] } }
  } do |ids, inputs|
    # Change the status of selected vulnerabilities
    Vulnerability.where(id: ids).update_all(status: inputs[:status])
    redirect_to collection_path, notice: "Status has been updated for selected vulnerabilities."
  end
end
