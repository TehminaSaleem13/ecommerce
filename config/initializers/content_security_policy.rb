# Be sure to restart your server when you modify this file.

Rails.application.config.content_security_policy do |policy|
  # Enable by default for development
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https, :unsafe_inline, :unsafe_eval
  policy.style_src   :self, :https, :unsafe_inline

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# Generate session nonces for permitted importmap, inline scripts, and inline styles.
Rails.application.config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

# Report violations without enforcing the policy.
# Rails.application.config.content_security_policy_report_only = true