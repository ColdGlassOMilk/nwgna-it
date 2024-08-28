ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    # attributes_table_for(resource) do
    #   row :email
    # end

    panel "Assigned Vulnerabilities" do
      table_for admin_user.vulnerabilities do
        column :id do |v|
          link_to v.id, admin_vulnerability_path(v)
        end
        column :description do |v|
          link_to v.name, admin_vulnerability_path(v)
        end
        column :severity
        column :ip_address
        column :target_tag
      end
    end

    active_admin_comments_for(resource)
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
