<?php
/**
 * Custom {%= post_type_name_capitalize %} Post Type
 *
 * @package WordPress
 * @subpackage {%= title_capitalize %}
 * @author {%= author %}
 * @link {%= author_uri %}
 *
 */

class {%= prefix_capitalize %}_Custom_{%= post_type_name_capitalize %} {

	function __construct() {
		add_action( 'init', array( $this, 'action_init' ) );
	}

	/**
	 * Register {%= post_type_name %} post type
	 * @return void
	 */
	function action_init() {
		$labels = array(
			'name'               => _x('{%= post_type_name_capitalize %}', '{%= post_type_name %}'),
			'singular_name'      => _x('{%= post_type_name_capitalize %}', '{%= post_type_name %}'),
			'add_new'            => _x('Add New', '{%= post_type_name %}'),
			'add_new_item'       => __('Add New {%= post_type_name_capitalize %}'),
			'edit_item'          => __('Edit {%= post_type_name_capitalize %}'),
			'new_item'           => __('New {%= post_type_name_capitalize %}'),
			'all_items'          => __('All {%= post_type_name_capitalize %}'),
			'view_item'          => __('View {%= post_type_name_capitalize %}'),
			'search_items'       => __('Search {%= post_type_name_capitalize %}'),
			'not_found'          => __('No {%= post_type_name_capitalize %} found'),
			'not_found_in_trash' => __('No {%= post_type_name_capitalize %} found in Trash'),
			'parent_item_colon'  => '',
			'menu_name'          => '{%= post_type_name %}'

			);
		$args = array(
			'labels'             => $labels,
			'public'             => true,
			'publicly_queryable' => true,
			'show_ui'            => true,
			'show_in_menu'       => true,
			'query_var'          => true,
			'rewrite'            => true,
			'capability_type'    => 'post',
			'has_archive'        => true,
			'hierarchical'       => false,
			'menu_position'      => 20,
			'supports'           => array( 'title', 'page-attributes', 'editor', 'thumbnail' ),
			'rewrite'            => array ( 'slug' => '{%= post_type_name %}', 'with_front' => false ),
			'taxonomies'         => array (
				0 => 'category',
				1 => 'post_tag',
			),
		);

		register_post_type('{%= post_type_name %}', $args);
	}
}

$custom_{%= post_type_name %} = new {%= prefix_capitalize %}_Custom_{%= post_type_name_capitalize %}();