/***
 *  $Id$
 **
 *  File: performance_indicators.hpp
 *  Created: May 9, 2012
 *
 *  Author: Olga Wodo, Baskar Ganapathysubramanian
 *  Copyright (c) 2012 Olga Wodo, Baskar Ganapathysubramanian
 *  See accompanying LICENSE.
 *
 *  This file is part of GraSPI.
 */

#ifndef PERFORMANCE_INDICATORS_HPP
#define PERFORMANCE_INDICATORS_HPP

#include "graspi_types.hpp"
#include "performance_indicators_abs.hpp"
#include "performance_indicators_diss.hpp"
#include "performance_indicators_charge_transport.hpp"
#include "graspi_descriptors.hpp"

#include <iostream>


namespace graspi {
    
    inline double perfomance_indicator( graph_t* G,
                                       const dim_g_t& d_g,
                                       const vertex_colors_t& C,
                                       const dim_a_t& d_a,
                                       const edge_weights_t& W,
                                       const edge_colors_t& L,
                                       const vertex_ccs_t& vCC,
                                       const ccs_t& CC,
                                       double pixelsize ) {
        
        //*****************************************************************//
        // Light absorption morphology descriptors:                        //
        //*****************************************************************//
        foo_w_abs wfoo_abs;
        double F_ABS = wf_abs(C,d_a,wfoo_abs,pixelsize);
        //*****************************************************************//
        // Exciton diffusion and dissociation morphology descriptors:      //
        //*****************************************************************//
        double Ld = 10;
        std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,BLACK,GREEN);
        //*****************************************************************//
        // Charge transport morphology descriptors:                        //
        //*****************************************************************//
        unsigned int n = boost::num_vertices(*G);
        std::vector<float> distances(n);
        compute_shortest_distance_from_sourceC_to_targetC(RED,BLACK,
                                                          G, d_g, C, W,
                                                          distances, std::string(""));
        double black_tort_1
        = determine_tortuosity( C, d_a, pixelsize, distances, RED, BLACK);
        
        for(unsigned int i=0; i<distances.size(); i++) distances[i] = 0;
        compute_shortest_distance_from_sourceC_to_targetC(BLUE,WHITE,
                                                          G, d_g, C, W,
                                                          distances, std::string(""));
        double white_tort_1
        = determine_tortuosity( C, d_a, pixelsize, distances, BLUE, WHITE);
        double F_CT = std::min (black_tort_1, white_tort_1);
        
        
        return F_ABS * F_DISS.first * F_CT;
    } // perfomance_indicator
    
    
    inline void all_perfomance_indicators_2phases(
                                                  graspi::DESC& descriptors,
                                                  graph_t* G,
                                                  const dim_g_t& d_g,
                                                  const vertex_colors_t& C,
                                                  const dim_a_t& d_a,
                                                  const edge_weights_t& W,
                                                  const edge_colors_t& L,
                                                  const vertex_ccs_t& vCC,
                                                  const ccs_t& CC,
                                                  double pixelsize) {
        
        //*****************************************************************//
        // Light absorption morphology descriptors:                        //
        //*****************************************************************//
        foo_w_abs wfoo_abs;
        double F_ABS = wf_abs(C,d_a,wfoo_abs,pixelsize);
        descriptors.update_desc("ABS_wf_D",F_ABS);
        
        std::pair<int,int> n_useful = find_useful_cc(descriptors, G, C, vCC, CC);
        //        int n_black_useful = n_useful.first;
        //        int n_white_useful = n_useful.second;
        
        double Ld = 10.0;
        std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,BLACK,GREEN);
        
        descriptors.update_desc("DISS_wf10_D",F_DISS.first);
        descriptors.update_desc("DISS_f10_D",F_DISS.second);
        
        std::pair<int,int> int_path =
        identify_complementary_paths_from_green(G,C,L,vCC,CC);
        
        descriptors.update_desc("STAT_e",int_path.first);
        descriptors.update_desc("CT_e_conn",int_path.second);
        double desc_tmp=((double)int_path.second)/((double)int_path.first);
        descriptors.update_desc("CT_f_e_conn",desc_tmp);
        
        //*****************************************************************//
        // Charge transport morphology descriptors:                        //
        //*****************************************************************//
        unsigned int n = boost::num_vertices(*G);
        std::vector<float> distances(n);
        std::set<int> id_blacks_conn_green_red;
        std::set<int> id_whites_conn_green_blue;
        
        //identify_black_vertices_connected_directly_to_interface
        identify_useful_triple_black_white_green( G, C, vCC, CC,
                                                 id_blacks_conn_green_red,
                                                 id_whites_conn_green_blue);
        
        descriptors.update_desc("CT_e_D_An",(float)id_blacks_conn_green_red.size());
        descriptors.update_desc("CT_e_A_Ca",(float)id_whites_conn_green_blue.size());
        
        
        // (1) determine the shorest distances from any black vertex to red and print to file
        // (2) print to file only these distances corresponding to vertices adjacent to interface
        // (3) compute tortuosity and print it
        compute_shortest_distance_from_sourceC_to_targetC(RED,BLACK,
                                                          G, d_g, C, W,
                                                          distances);
        double black_tort_1
        = determine_tortuosity( C, d_a, pixelsize,distances,RED,BLACK);
        
        descriptors.update_desc("CT_f_D_tort1",black_tort_1);
        
        // repeat three above steps for distanced from any white to red
        for(unsigned int i=0; i<distances.size(); i++) distances[i] = 0;
        compute_shortest_distance_from_sourceC_to_targetC(BLUE,WHITE,
                                                          G, d_g, C, W,
                                                          distances);
        double white_tort_1
        = determine_tortuosity( C, d_a, pixelsize,distances, BLUE,WHITE);
        descriptors.update_desc("CT_f_A_tort1",white_tort_1);
        
        //        descriptors.print_descriptors_2_phase(std::cout);
        
        
    } // perfomance_indicator_only_desc
    
    
    inline void all_perfomance_indicators_2phases(
                                                  graspi::DESC& descriptors,
                                                  std::ostream& os,
                                                  graph_t* G,
                                                  const dim_g_t& d_g,
                                                  const vertex_colors_t& C,
                                                  const dim_a_t& d_a,
                                                  const edge_weights_t& W,
                                                  const edge_colors_t& L,
                                                  const vertex_ccs_t& vCC,
                                                  const ccs_t& CC,
                                                  double pixelsize,
                                                  const std::string& res_path) {
        
        //*****************************************************************//
        // Light absorption morphology descriptors:                        //
        //*****************************************************************//
        std::string filename;
        foo_w_abs wfoo_abs;
        //      foo_no_w_abs wfoo_abs;
        double F_ABS = wf_abs(C,d_a,wfoo_abs,pixelsize);
        descriptors.update_desc("ABS_wf_D",F_ABS);
        
        //      os << "[F ABS] Weighted fraction of black vertices: " << F_ABS << std::endl;
        std::pair<int,int> n_useful = find_useful_cc(descriptors, G, C, vCC, CC);
        //      int n_black_useful = n_useful.first;
        //      int n_white_useful = n_useful.second;
        
        double Ld = 10.0;
        filename = res_path + std::string("DistancesBlackToGreen.txt");
        std::string wfilename = res_path + std::string("WDistancesBlackToGreen.txt");
        std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,BLACK,GREEN);
        
        //      os << "[F DISS] Weighted fraction of black vertices in " << Ld << " distance to interface: " << F_DISS.first << std::endl;
        //      os << "[F DISS] Fraction of black vertices in " << Ld << " distance to interface: " << F_DISS.second << std::endl;
        
        descriptors.update_desc("DISS_wf10_D",F_DISS.first);
        descriptors.update_desc("DISS_f10_D",F_DISS.second);
        
        
        std::pair<int,int> int_path =
        identify_complementary_paths_from_green(G,C,L,vCC,CC);
        //      os << "[F DISS] Number of interface edges: " << int_path.first << std::endl;
        //      os << "[STATS] Number of interface edges with complementary paths: " << int_path.second << std::endl;
        //      os << "[F CT] Fraction of interface with " << "complementary paths to bottom and top: " << ((double)int_path.second)/((double)int_path.first) << std::endl;
        
        descriptors.update_desc("STAT_e",int_path.first);
        descriptors.update_desc("CT_e_conn",int_path.second);
        double desc_tmp=((double)int_path.second)/((double)int_path.first);
        descriptors.update_desc("CT_f_e_conn",desc_tmp);
        
        
        //*****************************************************************//
        // Charge transport morphology descriptors:                        //
        //*****************************************************************//
        unsigned int n = boost::num_vertices(*G);
        std::vector<float> distances(n);
        std::set<int> id_blacks_conn_green_red;
        std::set<int> id_whites_conn_green_blue;
        
        //identify_black_vertices_connected_directly_to_interface
        identify_useful_triple_black_white_green( G, C, vCC, CC,
                                                 id_blacks_conn_green_red,
                                                 id_whites_conn_green_blue);
        //      os << "[STATS] Number of black interface vertices with path to top: " << id_blacks_conn_green_red.size() << std::endl;
        //      os << "[STATS] Number of white interface vertices with path to bottom: " << id_whites_conn_green_blue.size() << std::endl;
        
        descriptors.update_desc("CT_e_D_An",(float)id_blacks_conn_green_red.size());
        descriptors.update_desc("CT_e_A_Ca",(float)id_whites_conn_green_blue.size());
        
        
        // (1) determine the shorest distances from any black vertex to red and print to file
        // (2) print to file only these distances corresponding to vertices adjacent to interface
        // (3) compute tortuosity and print it
        filename = res_path + std::string("DistancesBlackToRed.txt");
        compute_shortest_distance_from_sourceC_to_targetC(RED,BLACK,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("DistancesGreenToRedViaBlack.txt");
        print_distances_of_ids(distances,id_blacks_conn_green_red,
                               filename);
        filename = res_path + std::string("TortuosityBlackToRed.txt");
        std::string id_t_filename = res_path + std::string("IdTortuosityBlackToRed.txt");
        double black_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename,RED,BLACK);
        //      os << "[F CT] Fraction of black vertices with straight rising paths"
        //	     << " (t=1): " << black_tort_1 << std::endl;
        
        descriptors.update_desc("CT_f_D_tort1",black_tort_1);
        
        // repeat three above steps for distanced from any white to red
        for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
        filename = res_path + std::string("DistancesWhiteToBlue.txt");
        compute_shortest_distance_from_sourceC_to_targetC(BLUE,WHITE,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("DistancesGreenToBlueViaWhite.txt");
        print_distances_of_ids(distances,id_whites_conn_green_blue,
                               filename);
        filename = res_path + std::string("TortuosityWhiteToBlue.txt");
        id_t_filename = res_path + std::string("IdTortuosityWhiteToBlue.txt");
        double white_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename, BLUE,WHITE);
        //      os << "[F CT] Fraction of white vertices with straight rising paths"
        //	 << " (t=1): " <<  white_tort_1 << std::endl;
        
        descriptors.update_desc("CT_f_A_tort1",white_tort_1);
        
        descriptors.print_descriptors_2_phase(std::cout);
        
        
    } // perfomance_indicator
    
    
    inline void all_perfomance_indicators_3phases(
                                                  graspi::DESC& descriptors,
                                                  std::ostream& os,
                                                  graph_t* G,
                                                  const dim_g_t& d_g,
                                                  const vertex_colors_t& C,
                                                  const dim_a_t& d_a,
                                                  const edge_weights_t& W,
                                                  const edge_colors_t& L,
                                                  const vertex_ccs_t& vCC,
                                                  const ccs_t& CC,
                                                  double pixelsize,
                                                  const std::string& res_path) {
        
        //*****************************************************************//
        // Light absorption morphology descriptors:                        //
        //*****************************************************************//
        std::string filename;
        foo_w_abs wfoo_abs;
        //      foo_no_w_abs wfoo_abs;
        double F_ABS = wf_abs(C,d_a,wfoo_abs,pixelsize);
        os << "[F ABS] Weighted fraction of black vertices: "
        << F_ABS << std::endl;
        std::pair<int,int> n_useful = find_useful_cc(descriptors, G, C, vCC, CC); // , os
        //      int n_black_useful = n_useful.first;
        //      int n_white_useful = n_useful.second;
        
        
        //*****************************************************************//
        // Exciton diffusion and dissociation morphology descriptors:      //
        //*****************************************************************//
        double Ld = 10.0;
        filename = res_path + std::string("DistancesBlackToGreen.txt");
        std::string wfilename = res_path + std::string("WDistancesBlackToGreen.txt");
        std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,BLACK,GREEN);
        os << "[F DISS] Weighted fraction of black vertices in "
        << Ld << " distance to interface: "
        << F_DISS.first << std::endl;
        os << "[F DISS] Fraction of black vertices in "
        << Ld << " distance to interface: "
        << F_DISS.second << std::endl;
        
        filename = res_path + std::string("DistancesGreyToLGreen.txt");
        wfilename = res_path + std::string("WDistancesGreyToLGreen.txt");
        F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,GREY,LGREEN);
        os << "[F DISS] Weighted fraction of grey vertices in "
        << Ld << " distance to grey-white interface: "
        << F_DISS.first << std::endl;
        os << "[F DISS] Fraction of grey vertices in "
        << Ld << " distance to grey-white interface: "
        << F_DISS.second << std::endl;
        
        
        //*****************************************************************//
        // Morphology descriptors related to the interface                 //
        //*****************************************************************//
        std::pair<int,int> int_path =
        identify_complementary_paths_from_green(G,C,L,vCC,CC);
        os << "[F DISS] Number of interface edges: "
        << int_path.first << std::endl;
        os << "[STATS] Number of interface edges with complementary paths: "
        << int_path.second << std::endl;
        os << "[F CT] Fraction of interface with "
        << "complementary paths to bottom and top: "
        << ((double)int_path.second)/((double)int_path.first) << std::endl;
        
        //*****************************************************************//
        // Charge transport morphology descriptors:                        //
        //*****************************************************************//
        unsigned int n = boost::num_vertices(*G);
        std::vector<float> distances(n);
        std::set<int> id_blacks_conn_green_red;
        std::set<int> id_whites_conn_green_blue;
        
        //identify_black_vertices_connected_directly_to_interface
        identify_useful_triple_black_white_green( G, C, vCC, CC,
                                                 id_blacks_conn_green_red,
                                                 id_whites_conn_green_blue);
        os << "[STATS] Number of black interface vertices with path to top: "
        << id_blacks_conn_green_red.size() << std::endl;
        os << "[STATS] Number of white interface vertices with path to bottom: "
        << id_whites_conn_green_blue.size() << std::endl;
        
        // (1) determine the shorest distances from any black vertex to red and print to file
        // (2) print to file only these distances corresponding to vertices adjacent to interface
        // (3) compute tortuosity and print it
        filename = res_path + std::string("DistancesBlackToRed.txt");
        compute_shortest_distance_from_sourceC_to_targetC(RED,BLACK,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("DistancesGreenToRedViaBlack.txt");
        print_distances_of_ids(distances,id_blacks_conn_green_red,
                               filename);
        filename = res_path + std::string("TortuosityBlackToRed.txt");
        std::string id_t_filename = res_path + std::string("IdTortuosityBlackToRed.txt");
        double black_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename,RED,BLACK);
        os << "[F CT] Fraction of black vertices with straight rising paths"
        << " (t=1): " << black_tort_1 << std::endl;
        
        // repeat three above steps for distanced from any white to red
        for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
        filename = res_path + std::string("DistancesWhiteToBlue.txt");
        compute_shortest_distance_from_sourceC_to_targetC(BLUE,WHITE,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("DistancesGreenToBlueViaWhite.txt");
        print_distances_of_ids(distances,id_whites_conn_green_blue,
                               filename);
        filename = res_path + std::string("TortuosityWhiteToBlue.txt");
        id_t_filename = res_path + std::string("IdTortuosityWhiteToBlue.txt");
        double white_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename, BLUE,WHITE);
        os << "[F CT] Fraction of white vertices with straight rising paths"
        << " (t=1): " <<  white_tort_1 << std::endl;
        
        // repeat three above steps for distanced from any grey to red
        for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
        filename = res_path + std::string("DistancesGreyToRed.txt");
        compute_shortest_distance_from_sourceC_to_targetC(RED,GREY,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("TortuosityGreyToRed.txt");
        id_t_filename = res_path + std::string("IdTortuosityGreyToRed.txt");
        double grey_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename, RED,GREY);
        os << "[F CT] Fraction of grey vertices with straight rising paths to top"
        << " (t=1): " <<  grey_tort_1 << std::endl;
        
        // repeat three above steps for distanced from any grey to blue
        for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
        filename = res_path + std::string("DistancesGreyToBlue.txt");
        compute_shortest_distance_from_sourceC_to_targetC(BLUE,GREY,
                                                          G, d_g, C, W,
                                                          distances, filename);
        filename = res_path + std::string("TortuosityGreyToBlue.txt");
        id_t_filename = res_path + std::string("IdTortuosityGreyToBlue.txt");
        grey_tort_1
        = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
                                         filename, id_t_filename, BLUE,GREY);
        os << "[F CT] Fraction of grey vertices with straight rising paths to bottom"
        << " (t=1): " <<  grey_tort_1 << std::endl;
        
        
    } // perfomance_indicator


inline void all_perfomance_indicators_5phases(
                                              graspi::DESC& descriptors,
                                              graph_t* G,
                                              const dim_g_t& d_g,
                                              const vertex_colors_t& C,
                                              const dim_a_t& d_a,
                                              const edge_weights_t& W,
                                              const edge_colors_t& L,
                                              const vertex_ccs_t& vCC,
                                              const ccs_t& CC,
                                              double pixelsize) {
    
    
    //*****************************************************************//
    // Light absorption morphology descriptors:                        //
    //*****************************************************************//
    foo_w_abs wfoo_abs;
    //      foo_no_w_abs wfoo_abs;
    double F_ABS = wf_abs(C,d_a,wfoo_abs,pixelsize);
//    std::cout << "[F ABS] Weighted fraction of black vertices: "
//    << F_ABS << std::endl;
    std::pair<int,int> n_useful = find_useful_cc_5phases(descriptors, G, C, vCC, CC); // , os
    int n_D_useful = n_useful.first; //both black and orange
    int n_A_useful = n_useful.second; // both white and yellow
    
    //*****************************************************************//
    // Exciton dissociation morphology descriptors:                        //
    //*****************************************************************//
    double Ld = 10.0;
//    std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,BLACK,GREEN);
//    std::pair<double,double> F_DISS_cr = wf_diss(G,d_g,C,W,vCC,CC,Ld,ORANGE,PURPLE);
    
    std::string filename = std::string("DistancesBlackToGreen.txt");
    std::string wfilename = std::string("WDistancesBlackToGreen.txt");
    std::pair<double,double> F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,BLACK,GREEN);
    descriptors.update_desc("DISS_wf10_D",F_DISS.first);
    descriptors.update_desc("DISS_f10_D",F_DISS.second);


    Ld=10;
    filename = std::string("DistancesOrangeToPurple.txt");
    wfilename = std::string("WDistancesOrangeToPurple.txt");
    std::pair<double,double> F_DISS_cr = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,ORANGE,PURPLE);
    descriptors.update_desc("DISS_wf_Dcr",F_DISS_cr.first);
    descriptors.update_desc("DISS_f_Dcr",F_DISS_cr.second);

    Ld=10;
    filename = std::string("DistancesWhiteToGreen.txt");
    wfilename = std::string("WDistancesWhiteToGreen.txt");
    F_DISS = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,WHITE,GREEN);
    descriptors.update_desc("DISS_wf_A",F_DISS.first);
    descriptors.update_desc("DISS_f_A",F_DISS.second);

    Ld=10;
    filename = std::string("DistancesYellowToPurple.txt");
    wfilename = std::string("WDistancesYellowToPurple.txt");
    F_DISS_cr = wf_diss(G,d_g,C,W,vCC,CC,Ld,filename,wfilename,YELLOW,PURPLE);
    descriptors.update_desc("DISS_wf_Acr",F_DISS_cr.first);
    descriptors.update_desc("DISS_f_Acr",F_DISS_cr.second);

    
    
    // (1) determine the shorest distances from any black vertex to red and print to file
    // (2) print to file only these distances corresponding to vertices adjacent to interface
    // (3) compute tortuosity and print it
    unsigned int n = boost::num_vertices(*G);
    std::vector<float> distances(n);
    filename = std::string("DistancesBlackOrangeGreyToRed.txt");
    std::vector<COLOR> colorsForEffectiveHoleTransportPaths;
    colorsForEffectiveHoleTransportPaths.push_back(BLACK);
    colorsForEffectiveHoleTransportPaths.push_back(ORANGE);
    colorsForEffectiveHoleTransportPaths.push_back(GREY);
    compute_shortest_distance_from_multipleSourceC_to_targetC(RED,colorsForEffectiveHoleTransportPaths,
                                                      G, d_g, C, W,
                                                      distances, filename);
//    filename = res_path + std::string("DistancesGreenToRedViaBlack.txt");
//    print_distances_of_ids(distances,id_blacks_conn_green_red,
//                           filename);
//    filename = res_path + std::string("TortuosityBlackToRed.txt");
//    std::string id_t_filename = res_path + std::string("IdTortuosityBlackToRed.txt");
//    double black_tort_1
//    = determine_and_print_tortuosity( C, d_a, pixelsize,distances,
//                                     filename, id_t_filename,RED,BLACK);
//    os << "[F CT] Fraction of black vertices with straight rising paths"
//    << " (t=1): " << black_tort_1 << std::endl;
    
    
    // repeat three above steps for distanced from any grey to red
    for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
    filename = std::string("DistancesWhiteYellowGreyToBlue.txt");
    std::vector<COLOR> colorsForEffectiveEleTransportPaths;
    colorsForEffectiveEleTransportPaths.push_back(WHITE);
    colorsForEffectiveEleTransportPaths.push_back(YELLOW);
    colorsForEffectiveEleTransportPaths.push_back(GREY);
    compute_shortest_distance_from_multipleSourceC_to_targetC(BLUE,colorsForEffectiveEleTransportPaths,
                                                      G, d_g, C, W,
                                                      distances, filename);

    
    descriptors.print_descriptors(std::cout);

}// all_performance_indicators_5phases
    


inline void distancesForEffectiveChargeTransport_5phases(graph_t* G,
                                                         const dim_g_t& d_g,
                                                         const vertex_colors_t& C,
                                                         const dim_a_t& d_a,
                                                         const edge_weights_t& W,
                                                         const edge_colors_t& L,
                                                         const vertex_ccs_t& vCC,
                                                         const ccs_t& CC,
                                                         double pixelsize){
    
#ifdef DEBUG
    // filter indices of vertices connected to green
    std::set<int> comp_conn_to_green;
    graspi::vertex_t source = d_g.id_green(); // bottom electrode index
    graspi::graph_t::adjacency_iterator u, u_end;
    boost::tie(u, u_end) = boost::adjacent_vertices(source, *G);
    for (; u != u_end; ++u) {
        comp_conn_to_green.insert(*u);
    }
    std::cout << "Inside distances" << std::endl;
    copy(comp_conn_to_green.begin(), comp_conn_to_green.end(),
         std::ostream_iterator<int>(std::cout, " "));
    
#endif


    unsigned int n = boost::num_vertices(*G);
    std::vector<float> distances(n);
    std::string filename = std::string("DistancesBlackOrangeGreyToGREEN.txt");
    std::vector<COLOR> colorsForEffectiveHoleTransportPaths;
    colorsForEffectiveHoleTransportPaths.push_back(BLACK);
    colorsForEffectiveHoleTransportPaths.push_back(ORANGE);
    colorsForEffectiveHoleTransportPaths.push_back(GREY);
    compute_shortest_distance_from_multipleSourceC_to_GREEN(colorsForEffectiveHoleTransportPaths,
                                                      G, d_g, C, W,
                                                      distances, filename);
    

    // repeat three above steps for distanced from any grey to red
    for(unsigned int  i=0; i<distances.size(); i++) distances[i] = 0;
    filename = std::string("DistancesWhiteYellowGreyToGREEN.txt");
    std::vector<COLOR> colorsForEffectiveEleTransportPaths;
    colorsForEffectiveEleTransportPaths.push_back(WHITE);
    colorsForEffectiveEleTransportPaths.push_back(YELLOW);
    colorsForEffectiveEleTransportPaths.push_back(GREY);
    compute_shortest_distance_from_multipleSourceC_to_GREEN(colorsForEffectiveEleTransportPaths,
                                                      G, d_g, C, W,
                                                      distances, filename);

    std::cout << "STAT_n " << d_g.n_bulk << std::endl;
}

} // namespace graspi

#endif // PERFORMANCE_INDICATORS_HPP
