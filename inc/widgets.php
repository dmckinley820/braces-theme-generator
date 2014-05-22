<?php
/**
 *
 * @package WordPress
 * @subpackage {%= title_capitalize %}
 * @author {%= author %}
 * @link {%= author_uri %}
 */

/**
 * Register widgetized area and update sidebar with default widgets
 */
function {%= prefix %}_widgets_init() {
	register_sidebar( array(
		'name'          => __( 'Sidebar', '{%= prefix %}' ),
		'id'            => 'sidebar-1',
		'before_widget' => '<aside id="%1$s" class="widget %2$s">',
		'after_widget'  => '</aside>',
		'before_title'  => '<h1 class="widget-title">',
		'after_title'   => '</h1>',
	) );
}
add_action( 'widgets_init', '{%= prefix %}_widgets_init' );
