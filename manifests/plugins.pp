# Class: jenkins::plugins
#
class jenkins::plugins (
  $plugin_hash = {},
  $plugin_parent_dir = '/var/lib/jenkins',
  $plugin_dir        = "$plugin_parent_dir/plugins",
) {
  validate_hash( $plugin_hash )

  $defaults = {
    'plugin_parent_dir'   => $plugin_parent_dir,
    'plugin_dir'          => $plugin_dir,
  }

  create_resources('jenkins::plugin', $plugin_hash, $defaults)
}
