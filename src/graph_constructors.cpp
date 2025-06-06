#include <iostream>
#include "graph_constructors.hpp"
#include "graspi_predicates.hpp"
#include <boost/graph/connected_components.hpp>
#include <boost/graph/filtered_graph.hpp>


bool graspi::build_graph(const std::string& name,
                         graph_t*& G,
                         dim_g_t& d_g,
                         vertex_colors_t& C,
                         edge_weights_t& W,
                         edge_colors_t& L) {
    std::ifstream f(name.c_str());
    if (!f) return false;
    return build_graph(f, G, d_g, C, W, L);
} // build_graph


bool graspi::build_graph(graph_t*& G, const dim_g_t& d_g,
                         vertex_colors_t& C, dim_a_t& d_a,
                         edge_weights_t& W,
                         edge_colors_t& L,
                         double pixelsize, bool if_per_on_size);

void graspi::initlize_colors_meta_vertices( vertex_colors_t& C, const dim_g_t& d_g ){
    
    //    std::cerr << "Test: " << C.size() << " " << d_g.n_bulk << std::endl;
    
    C[d_g.n_bulk]   = BLUE;  // bottom electrode
    C[d_g.n_bulk+1] = RED;   // top electrode
    C[d_g.n_bulk+2] = GREEN; // meta vertex - I D/A
    if(d_g.n_phases == 3){
        C[d_g.n_bulk+3] = DGREEN; // meta vertex - I D/D+A
        C[d_g.n_bulk+4] = LGREEN; // meta vertex - I A/D+A
    }

    if(d_g.n_phases == 5){
        C[d_g.n_bulk+3] = DGREEN; // meta vertex - I D/D+A
        C[d_g.n_bulk+4] = LGREEN; // meta vertex - I A/D+A
        C[d_g.n_bulk+5] = PURPLE; // meta vertex - I A/D+A
        C[d_g.n_bulk+6] = DPINK; //   34 // interface (I Dcr/Aam)
        C[d_g.n_bulk+7] = DPINK;//   35 // interface (I Dcr/Mixed)
        C[d_g.n_bulk+8] = DPINK;//   36 // interface (I Dcr/Dam)

        C[d_g.n_bulk+9]  = LPINK;//   37 // interface (I Acr/Dam)
        C[d_g.n_bulk+10] = LLPINK;//  38 // interface (I Acr/Mixed)
        C[d_g.n_bulk+11] = LLLPINK;// 39 // interface (I Acr/Aam)
      
    }

    
}

template <typename Container>
bool graspi::update_graph(const Container& M, const dim_a_t& d,
                          graph_t& G, dim_g_t& d_g,
                          vertex_colors_t& C,
                          edge_weights_t& W,
                          edge_colors_t& L) {
    // no error checking
    C.resize( M.size()+d_g.n_meta() );
    for (unsigned int i = 0; i < M.size(); ++i) C[i] = M[i];
    
    //      initlize_color_meta_vertices( C, d_g );
    return true;
} // update_graph


/*
 * Function adds/updates edges to the graph
 * between interface meta-vertex and bulk vertices
 * with corresponding attributes
 * s      - source vertex to be checked
 * meta_t - meta vertex to which edge is linked
 * w,o    - attributes of new edges
 */

bool graspi::build_graph(std::istream& is,
                         graph_t*& G,
                         dim_g_t& d_g,
                         vertex_colors_t& C,
                         edge_weights_t& W,
                         edge_colors_t& L){
    
    // n is size of graphe w/o special vertices
    unsigned int n = 0;
    
    if(!is) {
        std::cerr << "Problem with istream!" << std::endl;
        return false;
    }
    
    int n_of_vertices = 1;
    int green_vertex, lgreen_vertex, dgreen_vertex;
    int purple_vertex, dpink_vertex, ddpink_vertex, dddpink_vertex, lpink_vertex, llpink_vertex, lllpink_vertex;
    
    int i=0;
    do {
        std::string tmp;
        getline(is,tmp);
        std::istringstream iss(tmp);
        if(!is) {
            std::cerr << "Problem with input file - line " << i << std::endl;
            delete G;
            return false;
        }
        
        if(i==0){
            iss >> n_of_vertices;
            n = n_of_vertices;
            d_g.n_bulk = n_of_vertices;
            G = new graspi::graph_t( d_g.n_total() );
            C.resize(d_g.n_total(), 13);
            initlize_colors_meta_vertices(C,d_g);
            green_vertex = d_g.n_bulk+2;
            if(d_g.n_phases == 3){
                dgreen_vertex = d_g.n_bulk+3;
                lgreen_vertex = d_g.n_bulk+4;
            }
            if(d_g.n_phases == 5){
                dgreen_vertex  = d_g.n_bulk+3;
                lgreen_vertex  = d_g.n_bulk+4;
                purple_vertex  = d_g.n_bulk+5;
                dpink_vertex   = d_g.n_bulk+6;
                ddpink_vertex  = d_g.n_bulk+7;
                dddpink_vertex = d_g.n_bulk+8;
                lpink_vertex   = d_g.n_bulk+9;
                llpink_vertex  = d_g.n_bulk+10;
                lllpink_vertex = d_g.n_bulk+11;
            }


        }
        
        if( (i>0) && ( i <= n_of_vertices ) ){
            int s = 0;
            iss >> s;
            iss >> C[s];
            int t = 0;
            double w = 0.0;
            char o;
            do{
                iss >> t;
                iss >> w;
                iss >> o;
                
                if(!iss ) break;
                
                if (t == -3) continue;
                if (t < 0) {
                    t = n-t-1;
                    w = 0;
                    o = 's';
                }
                add_edge_to_graph(s, t, o, w,
                                  green_vertex, dgreen_vertex, lgreen_vertex,
                                  G,C,W,L);
                
            }while(iss);
            
        }
        
        if( i > n_of_vertices ){
            int s = 0;
            iss >> s;
            iss >> C[s];
            int t = 0;
            double w = 0.0;
            char o;
            do{
                iss >> t;
                iss >> w;
                iss >> o;
                
                if(!iss ) break;
                
                if (t == -3) continue;
                if (t < 0) {
                    t = n-t-1;
                    w = 0;
                    o = 's';
                }
                add_edge_to_graph(s, t, o, w,
                                  green_vertex, dgreen_vertex, lgreen_vertex,
                                  G,C,W,L);
            }while(iss);
        }
        if (i >= (n_of_vertices+2) ) break;
        i++;
    }while(is);
    
    
    return true;
}//build_graph



bool graspi::build_graph(graph_t*& G, const dim_g_t& d_g,
                         vertex_colors_t& C, dim_a_t& d_a,
                         edge_weights_t& W,
                         edge_colors_t& L,
                         double pixelsize, bool if_per_on_size
                         ) {
    
    G = new graspi::graph_t( d_g.n_total() );
    int n = d_g.n_bulk;
#ifdef DEBUG
    std::cout << "n: " << n << std::endl;
#endif
    
    if(d_a.nz == 0) d_a.nz = 1;
    initlize_colors_meta_vertices( C, d_g );
    int green_vertex, lgreen_vertex, dgreen_vertex;
    int purple_vertex, dpink_vertex, ddpink_vertex, dddpink_vertex, lpink_vertex, llpink_vertex, lllpink_vertex;

    green_vertex = d_g.n_bulk+2;
    if(d_g.n_phases == 3){
        dgreen_vertex = d_g.n_bulk+3;
        lgreen_vertex = d_g.n_bulk+4;
    }
    if(d_g.n_phases == 5){
        dgreen_vertex  = d_g.n_bulk+3;
        lgreen_vertex  = d_g.n_bulk+4;
        purple_vertex  = d_g.n_bulk+5;
        dpink_vertex   = d_g.n_bulk+6;
        ddpink_vertex  = d_g.n_bulk+7;
        dddpink_vertex = d_g.n_bulk+8;
        lpink_vertex   = d_g.n_bulk+9;
        llpink_vertex  = d_g.n_bulk+10;
        lllpink_vertex = d_g.n_bulk+11;
    }

    
    int ngbr_size = 8;
    if(d_a.nz > 1) ngbr_size = 26;
    std::pair<int,char>* ngbr = new std::pair<int,char> [ngbr_size];
    
    for(unsigned int k = 0; k < d_a.nz; k++){
        for(unsigned int j = 0; j < d_a.ny; j++){
            for(unsigned int i = 0; i < d_a.nx; i++){
                generate_ngbr(i,j,k,d_a,ngbr,if_per_on_size);
                
                int id = i + d_a.nx * ( j + d_a.ny * k );
                int s = id;
                for (int i_ngbr=0; i_ngbr < ngbr_size; i_ngbr++){
                    int t = ngbr[i_ngbr].first;
                    char o = ngbr[i_ngbr].second;
                    double w = 1.0 * pixelsize;
                    if( o == 's') w = sqrt(2.0) * pixelsize;
                    if( o == 't') w = sqrt(3.0) * pixelsize;
                    
                    if (t == -3) continue;
                    // for metavertices corresponding to electrode correct indices
                    // old: cathode has index:-1 in the inputdata
                    // new: cathode has index: n_bulk+1 (appended at the end)
                    // similar operation applied to anode
                    // anode has index : n_bulk+2
                    if (t < 0){
                        t = n-t-1;
                        o = 's';
                        w = 0.0;
                    }
#ifdef DEBUG
                    std::cerr << "( " << s << "," << t << " )"
                    << o << " " << w << " , "
                    << C[s] << " " << C[t] << std::endl;
#endif
                    
                    if (d_g.n_phases == 5)
                        add_edge_to_graph(s, t, o, w,
                                          green_vertex,
                                          dgreen_vertex,
                                          lgreen_vertex,
                                          purple_vertex,
                                          dpink_vertex, ddpink_vertex, dddpink_vertex,
                                          lpink_vertex, llpink_vertex, lllpink_vertex,
                                          G,C,W,L);
                    else
                        add_edge_to_graph(s, t, o, w,
                                          green_vertex,
                                          dgreen_vertex,
                                          lgreen_vertex,
                                          G,C,W,L);

                }
            }//i
        }//j
    }//k
    
    delete[] ngbr;
    
    return true;
} // build_graph


bool graspi::build_graph_for_effective_paths(graph_t*& G, const dim_g_t& d_g,
                         vertex_colors_t& C, dim_a_t& d_a,
                         edge_weights_t& W,
                         edge_colors_t& L,
                         double pixelsize, bool if_per_on_size
                         ) {
    
    //step 1: create graph for the discovery of effective paths, this graph will be destroyed in step 3
    //        this initial graph consist of basic labels: black orange grey yellow white, and two meta-vertices: red and blue

    
    graph_t* G0 = new graspi::graph_t( d_g.n_total() );
    int n = d_g.n_bulk;
    if(d_a.nz == 0) d_a.nz = 1;
    C[d_g.n_bulk]   = BLUE;  // bottom electrode
    C[d_g.n_bulk+1] = RED;   // top electrode
    C[d_g.n_bulk+2] = GREEN; // meta vertex - I D/A
    int green_vertex = d_g.n_bulk+2;
    
    int ngbr_size = 8;
    if(d_a.nz > 1) ngbr_size = 26;
    std::pair<int,char>* ngbr0 = new std::pair<int,char> [ngbr_size];
    
    for(unsigned int k = 0; k < d_a.nz; k++){
        for(unsigned int j = 0; j < d_a.ny; j++){
            for(unsigned int i = 0; i < d_a.nx; i++){
                generate_ngbr(i,j,k,d_a,ngbr0,if_per_on_size);
                
                int id = i + d_a.nx * ( j + d_a.ny * k );
                int s = id;
                for (int i_ngbr=0; i_ngbr < ngbr_size; i_ngbr++){
                    int t = ngbr0[i_ngbr].first;
                    char o = ngbr0[i_ngbr].second;
                    double w = 1.0 * pixelsize;
                    if( o == 's') w = sqrt(2.0) * pixelsize;
                    if( o == 't') w = sqrt(3.0) * pixelsize;
                    
                    if (t == -3) continue;
                    // for metavertices corresponding to electrode correct indices
                    // old: cathode has index:-1 in the inputdata
                    // new: cathode has index: n_bulk+1 (appended at the end)
                    // similar operation applied to anode
                    // anode has index : n_bulk+2
                    if (t < 0){
                        t = n-t-1;
                        o = 's';
                        w = 0.0;
                    }
                    
                    
                    graspi::edge_descriptor_t e;
                    bool e_res = false;
                    
                    boost::tie(e, e_res) = boost::edge(s, t, *G0);
                    if (e_res == false) {
                        boost::tie(e, e_res) = boost::add_edge(s, t, *G0);
                    }
                    

                }
            }//i
        }//j
    }//k
    
    delete[] ngbr0;
    
    
    
    //step 2: find the vector of features of connected components and check if they are connected to top,  bottom or both
    int size_of_G = boost::num_vertices(*G0);
    //effectiveHoleTransport (Black Orange Grey)
    graspi::vertex_ccs_t vCCsEHT;      //container storing CC-indices of vertices for effective Hole Transport
    connect_multipleBOG_same_color predH(*G0, C);
    boost::filtered_graph<graspi::graph_t,connect_multipleBOG_same_color> FGH(*G0, predH);
    vCCsEHT.resize(size_of_G, 0);
    boost::connected_components(FGH, &vCCsEHT[0]);

#ifdef DEBUG
    for (unsigned int  i = 0; i < vCCsEHT.size(); i++){
        std::cout << "(" << C[i] << "," << vCCsEHT[i] << ")";
    }
    std::cout << std::endl;
#endif

    //effectiveElectronTransport (White Yellow Grey)
    graspi::vertex_ccs_t vCCsEET;      //container storing CC-indices of vertices for effective Electrone Transport
    connect_multipleWYG_same_color predE(*G0, C);
    boost::filtered_graph<graspi::graph_t,connect_multipleWYG_same_color> FGE(*G0, predE);
    vCCsEET.resize(size_of_G, 0);
    boost::connected_components(FGE, &vCCsEET[0]);

#ifdef DEBUG
    for (unsigned int  i = 0; i < vCCsEET.size(); i++){
        std::cout << "(" << C[i] << "," << vCCsEET[i] << ")";
    }
    std::cout << std::endl;
#endif


    // filter indices of CC to check if connected EHT
    // determine all vertices connected to the top electrode
    std::set<int> comp_conn_to_red_electrode;
    graspi::vertex_t source = d_g.id_red(); // top electrode index
    graspi::graph_t::adjacency_iterator u, u_end;
    boost::tie(u, u_end) = boost::adjacent_vertices(source, *G0);
    for (; u != u_end; ++u) {
        comp_conn_to_red_electrode.insert(vCCsEHT[*u]);
    }
    std::vector<int>::const_iterator itH = max_element( vCCsEHT.begin(),
                                                      vCCsEHT.end() );
    ccs_t CCsEHT;
    CCsEHT.resize( (*itH)+1 );
    for (unsigned int  i = 0; i < vCCsEHT.size(); i++){
        if ( ( C[i] == BLACK) || ( C[i] == ORANGE) || ( C[i] == GREY) )
            CCsEHT[vCCsEHT[i]].color = 101;
        else CCsEHT[vCCsEHT[i]].color = C[i];

        CCsEHT[vCCsEHT[i]].size++;
    }
    // pass info about connectivity to top electrode to data of components
    for(unsigned int  i = 0; i < CCsEHT.size(); i++ ){
        if( comp_conn_to_red_electrode.find(i) != comp_conn_to_red_electrode.end() )
            CCsEHT[i].if_connected_to_electrode += 1;
    }

#ifdef DEBUG
        std::cout << "Id of connected components connected to top " << std::endl;
        copy(comp_conn_to_red_electrode.begin(), comp_conn_to_red_electrode.end(),
             std::ostream_iterator<int>(std::cout, " "));
        std::cout << std::endl;

#endif

    
    
    // filter indices of CC to check if connected EET
    std::set<int> comp_conn_to_blue_electrode;
    source = d_g.id_blue(); // bottom electrode index
//    graspi::graph_t::adjacency_iterator u, u_end;
    boost::tie(u, u_end) = boost::adjacent_vertices(source, *G0);
    for (; u != u_end; ++u) {
        comp_conn_to_blue_electrode.insert(vCCsEET[*u]);
    }
    std::vector<int>::const_iterator itE = max_element( vCCsEET.begin(),
                                                      vCCsEET.end() );
    ccs_t CCsEET;
    CCsEET.resize( (*itE)+1 );
    for (unsigned int  i = 0; i < vCCsEET.size(); i++){
        if ( ( C[i] == WHITE) || ( C[i] == YELLOW) || ( C[i] == GREY) )
            CCsEET[vCCsEET[i]].color = 102;
        else CCsEET[vCCsEET[i]].color = C[i];

        CCsEET[vCCsEET[i]].size++;
    }
    // pass info about connectivity to top electrode to data of components
    for(unsigned int  i = 0; i < CCsEET.size(); i++ ){
        if( comp_conn_to_blue_electrode.find(i) != comp_conn_to_blue_electrode.end() )
            CCsEET[i].if_connected_to_electrode += 1;
    }
    
#ifdef DEBUG
        std::cout << "Id of connected components connected to bottom " << std::endl;
        copy(comp_conn_to_blue_electrode.begin(), comp_conn_to_blue_electrode.end(),
             std::ostream_iterator<int>(std::cout, " "));
        std::cout << std::endl;

#endif

    
    //step 3: destroy the initial graph
    delete G0;
    
    //step 4: create the second graph, this time add the edges between effective charge transport regions only.

    std::ofstream fileIdOfETmixed("IdsETmixed.txt");//Ids3a.txt");
    std::ofstream fileIdOfEETacceptor("IdsEETacceptor.txt");//Ids3b.txt");
    std::ofstream fileIdOfEHTdonor("IdsEHTdonor.txt");//Ids3c.txt");

    std::ofstream fileIdOfEHT("IdsEHT.txt");
    std::ofstream fileIdOfEET("IdsEET.txt");

    
    G = new graspi::graph_t( d_g.n_total() );
    n = d_g.n_bulk;
#ifdef DEBUG
    std::cout << "n: " << n << std::endl;
#endif
    
    if(d_a.nz == 0) d_a.nz = 1;
    C[d_g.n_bulk]   = BLUE;  // bottom electrode
    C[d_g.n_bulk+1] = RED;   // top electrode
    C[d_g.n_bulk+2] = GREEN; // meta vertex - I D/A
    green_vertex = d_g.n_bulk+2;
    
    std::pair<int,char>* ngbr = new std::pair<int,char> [ngbr_size];
    
    std::set<std::pair<int,int> > setOfIndicesGREYinET;
    std::set<std::pair<int,int> > setOfIndicesEEHTatInterface;
    std::set<std::pair<int,int> > setOfIndicesEHHTatInterface;
    
    std::pair<int,int> pairForDescET; //effective interface+mixed descriptor

    for(unsigned int k = 0; k < d_a.nz; k++){
        for(unsigned int j = 0; j < d_a.ny; j++){
            for(unsigned int i = 0; i < d_a.nx; i++){
                
                generate_ngbr(i,j,k,d_a,ngbr,if_per_on_size);
                
                int id = i + d_a.nx * ( j + d_a.ny * k );
                int s = id;
                for (int i_ngbr=0; i_ngbr < ngbr_size; i_ngbr++){
                    int t = ngbr[i_ngbr].first;
                    char o = ngbr[i_ngbr].second;
                    double w = 1.0 * pixelsize;
                    if( o == 's') w = sqrt(2.0) * pixelsize;
                    if( o == 't') w = sqrt(3.0) * pixelsize;
                    
                    if (t == -3) continue;
                    // for metavertices corresponding to electrode correct indices
                    // old: cathode has index:-1 in the inputdata
                    // new: cathode has index: n_bulk+1 (appended at the end)
                    // similar operation applied to anode
                    // anode has index : n_bulk+2
                    if (t < 0){
                        t = n-t-1;
                        o = 's';
                        w = 0.0;
                    }
                    //#ifdef DEBUG
                    //                    std::cerr << "( " << s << "," << t << " )"
                    //                    << o << " " << w << " , "
                    //                    << C[s] << " " << C[t] << std::endl;
                    //#endif
                    
                    graspi::edge_descriptor_t e;
                    bool e_res = false;
                    
                    boost::tie(e, e_res) = boost::edge(s, t, *G);
                    if (e_res == false) {
                        boost::tie(e, e_res) = boost::add_edge(s, t, *G);
                        std::pair<int,int> p = std::pair<int,int>(std::min(s,t),
                                                                  std::max(s,t));
                        W[e] = w;
                        L[p] = o;
                    }
                    
                    
                    bool connectityFlagOfSource = false;
                    if( (C[s]==BLACK) || (C[s]==ORANGE) ){
                        connectityFlagOfSource = CCsEHT[vCCsEHT[s]].if_connected_to_electrode;
                        if(connectityFlagOfSource) fileIdOfEHT << i << " " << j << " " << C[s] <<std::endl;
                    }
                    if ( (C[s]==WHITE) || (C[s]==YELLOW) ){
                        connectityFlagOfSource = CCsEET[vCCsEET[s]].if_connected_to_electrode;
                        if (connectityFlagOfSource ) fileIdOfEET << i << " " << j << " " << C[s] <<std::endl;
                    }
                    if ( (C[s]==GREY) && (CCsEHT[vCCsEHT[s]].if_connected_to_electrode) && (CCsEET[vCCsEET[s]].if_connected_to_electrode) ){
                        connectityFlagOfSource = true;
//                        fileIdOfEHT << i << " " << j << " " << C[s] <<std::endl;
//                        fileIdOfEET << i << " " << j << " " << C[s] <<std::endl;
                    }

                    if (C[s]==GREY){
                        if (CCsEHT[vCCsEHT[s]].if_connected_to_electrode) fileIdOfEHT << i << " " << j << " " << C[s] <<std::endl;
                        if (CCsEET[vCCsEET[s]].if_connected_to_electrode) fileIdOfEET << i << " " << j << " " << C[s] <<std::endl;
                    }

                    
                    
                    
                    
                    bool connectityFlagOfTarget = false;
                    if( (C[t]==BLACK) || (C[t]==ORANGE) )
                        connectityFlagOfTarget = CCsEHT[vCCsEHT[t]].if_connected_to_electrode;
                    if ( (C[t]==WHITE) || (C[t]==YELLOW) )
                        connectityFlagOfTarget = CCsEET[vCCsEET[t]].if_connected_to_electrode;
                    if ( (C[t]==GREY) && (CCsEHT[vCCsEHT[t]].if_connected_to_electrode) && (CCsEET[vCCsEET[t]].if_connected_to_electrode) ){
                        connectityFlagOfTarget = true;
                        //                        std::cout << t << " ";
                        
                    }
                    
                    if((C[s]+C[t] == 1) && (connectityFlagOfSource) && (connectityFlagOfTarget)){
                        
                        if (C[s] == WHITE) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            //add edge between white and green (only if path exists)
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[s] == BLACK) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            //add edge between white and green (only if path exists)
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == WHITE) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            //add edge between black and green (only if path exists)
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == BLACK) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            //add edge between black and green (only if path exists)
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
                        
#ifdef DEBUG
                        std::cerr << "added1( " << s << "," << t << " )" << C[s] << " " << C[t] << std::endl;
#endif
                        
                        
                    }//I D/A
                    
                    if( (C[s]!=C[t] )&& (C[s]+C[t] == 6)&& (connectityFlagOfSource) && (connectityFlagOfTarget)){// White and Orange
                        
                       
                        if (C[s] == WHITE) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[s] == ORANGE) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                               w, o, G, W, L);
                        }
                        if (C[t] == WHITE) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);

                        }
                        if (C[t] == ORANGE) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);

                        }
#ifdef DEBUG
                    std::cerr << "added2( " << s << "," << t << " )" << C[s] << " " << C[t] << std::endl;
#endif
                    }//I
                    
//                    if((C[s]!=C[t] )&&(C[s]+C[t] == 4)&& (connectityFlagOfSource) && (connectityFlagOfTarget)){// White and Grey
//                        make_update_edge_with_meta_vertex( s, green_vertex,
//                                                          w, o, G, W, L);
//                        make_update_edge_with_meta_vertex( t, green_vertex,
//                                                          w, o, G, W, L);
//                    }//I
                    
                    if((C[s]!=C[t] )&&(C[s]+C[t] == 7)&& (connectityFlagOfSource) && (connectityFlagOfTarget)){// Yellow and Black
                        
                        
                        if (C[s] == YELLOW) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);

                        }
                        if (C[s] == BLACK) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == YELLOW) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == BLACK) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
#ifdef DEBUG
                    std::cerr << "added4( " << s << "," << t << " )" << C[s] << " " << C[t] << std::endl;
#endif
                    }//I
                    if((C[s]!=C[t] )&&(C[s]+C[t] == 12)&& (connectityFlagOfSource) && (connectityFlagOfTarget)){// Yellow and Orange
                        
                        
                        if (C[s] == YELLOW) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[s] == ORANGE) {
                            pairForDescET = std::make_pair(s, C[s]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( s, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == YELLOW) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEHHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
                        if (C[t] == ORANGE) {
                            pairForDescET = std::make_pair(t, C[t]);
                            setOfIndicesEEHTatInterface.insert(pairForDescET);
                            make_update_edge_with_meta_vertex( t, green_vertex,
                                                              w, o, G, W, L);
                        }
#ifdef DEBUG
                    std::cerr << "added5( " << s << "," << t << " )" << C[s] << " " << C[t] << std::endl;
#endif
                    }//I
                    
                    if( (C[s] == GREY)  && (connectityFlagOfSource) ){
                        pairForDescET = std::make_pair(s, C[s]);
                        setOfIndicesGREYinET.insert(pairForDescET);
                        w=0.0;
                        make_update_edge_with_meta_vertex( s, green_vertex,
                                                          w, o, G, W, L);

#ifdef DEBUG
                    std::cerr << "added9( " << s << " " << C[s] << std::endl;
#endif
                    }//bulk

                    
                    if( (C[t] == GREY)  && (connectityFlagOfTarget) ){
                        pairForDescET = std::make_pair(t, C[t]);
                        setOfIndicesGREYinET.insert(pairForDescET); //std::cout << t << " ";
                        w=0.0;
                        make_update_edge_with_meta_vertex( t, green_vertex,
                                                          w, o, G, W, L);

#ifdef DEBUG
                    std::cerr << "added9( " << t << " " << C[t] << std::endl;
#endif
                    }//bulk

                }//neighbors
                
            }//i
        }//j
    }//k
    
    for (std::set<std::pair<int, int> >::iterator it = setOfIndicesGREYinET.begin(); it != setOfIndicesGREYinET.end(); ++it) {
        int idx = it->first / d_a.nx;
        int idy = it->first % d_a.nx;
        fileIdOfETmixed << idy << " " << idx << " " << it->first << " " << it->second << std::endl;
        }

    for (std::set<std::pair<int, int> >::iterator it = setOfIndicesEEHTatInterface.begin(); it != setOfIndicesEEHTatInterface.end(); ++it) {
        int idx = it->first / d_a.nx;
        int idy = it->first % d_a.nx;
        fileIdOfEETacceptor << idy << " " << idx << " " << it->first << " " << it->second << std::endl;
        }

    for (std::set<std::pair<int, int> >::iterator it = setOfIndicesEHHTatInterface.begin(); it != setOfIndicesEHHTatInterface.end(); ++it) {
        int idx = it->first / d_a.nx;
        int idy = it->first % d_a.nx;
        fileIdOfEHTdonor << idy << " " << idx << " " << it->first << " " << it->second << std::endl;
        }

#ifdef DEBUG

    // filter indices of vertices connected to green
    std::set<int> comp_conn_to_green;
    source = d_g.id_green(); // bottom electrode index
//    graspi::graph_t::adjacency_iterator u, u_end;
    boost::tie(u, u_end) = boost::adjacent_vertices(source, *G0);
    for (; u != u_end; ++u) {
        comp_conn_to_green.insert(*u);
    }
    std::cout << std::endl;
    copy(comp_conn_to_green.begin(), comp_conn_to_green.end(),
         std::ostream_iterator<int>(std::cout, " "));
    
#endif

    std::cout << "n_M_eff:" << setOfIndicesGREYinET.size() << std::endl;
    std::cout << "e_A_eff:" << setOfIndicesEEHTatInterface.size() << std::endl;
    std::cout << "e_D_eff:" << setOfIndicesEHHTatInterface.size() << std::endl;
    

    
    fileIdOfETmixed.close();
    fileIdOfEETacceptor.close();
    fileIdOfEHTdonor.close();
    
    fileIdOfEET.close();
    fileIdOfEHT.close();

    delete[] ngbr;
    
    return true;
} // build_graph


void graspi::add_edge_to_graph(int s, int t, char o, double w,
                               int green_vertex,
                               int dgreen_vertex,
                               int lgreen_vertex,
                               graph_t* G,
                               vertex_colors_t& C,
                               edge_weights_t& W,
                               edge_colors_t& L) {
    
    graspi::edge_descriptor_t e;
    bool e_res = false;
    
    boost::tie(e, e_res) = boost::edge(s, t, *G);
    if (e_res == false) {
        boost::tie(e, e_res) = boost::add_edge(s, t, *G);
        std::pair<int,int> p = std::pair<int,int>(std::min(s,t),
                                                  std::max(s,t));
        W[e] = w;
        L[p] = o;
    }
    
    if(C[s]+C[t] == 1){
        //add edge between white and green
        make_update_edge_with_meta_vertex( s, green_vertex,
                                          w, o, G, W, L);
        //add edge between black and green
        make_update_edge_with_meta_vertex( t, green_vertex,
                                          w, o, G, W, L);
    }//I D/A
    
    if(C[s]+C[t] == 3){
        //add edge between black and dgreen
        make_update_edge_with_meta_vertex( s, dgreen_vertex,
                                          w, o, G, W, L);
        //add edge between grey and green
        make_update_edge_with_meta_vertex( t, dgreen_vertex,
                                          w, o, G, W, L);
    }//I D/D+A
    
    if(C[s]+C[t] == 4){
        //add edge between white and lgreen
        make_update_edge_with_meta_vertex( s, lgreen_vertex,
                                          w, o, G, W, L);
        //add edge between grey and lgreen
        make_update_edge_with_meta_vertex( t, lgreen_vertex,
                                          w, o, G, W, L);
    }//I A/D+A
    
}

void graspi::add_edge_to_graph(int s, int t, char o, double w,
                               int green_vertex,
                               int dgreen_vertex,
                               int lgreen_vertex,
                               int purple_vertex,
                               int dpink_vertex, int ddpink_vertex, int dddpink_vertex,
                               int lpink_vertex, int llpink_vertex, int lllpink_vertex,
                               graph_t* G,
                               vertex_colors_t& C,
                               edge_weights_t& W,
                               edge_colors_t& L) {
    
    graspi::edge_descriptor_t e;
    bool e_res = false;
    
    boost::tie(e, e_res) = boost::edge(s, t, *G);
    if (e_res == false) {
        boost::tie(e, e_res) = boost::add_edge(s, t, *G);
        std::pair<int,int> p = std::pair<int,int>(std::min(s,t),
                                                  std::max(s,t));
        W[e] = w;
        L[p] = o;
    }
    
    if(C[s]+C[t] == 1){
        //add edge between white and green
        make_update_edge_with_meta_vertex( s, green_vertex,
                                          w, o, G, W, L);
        //add edge between black and green
        make_update_edge_with_meta_vertex( t, green_vertex,
                                          w, o, G, W, L);
    }//I D/A
    
    if(C[s]+C[t] == 3){
        //add edge between black and dgreen
        make_update_edge_with_meta_vertex( s, dgreen_vertex,
                                          w, o, G, W, L);
        //add edge between grey and green
        make_update_edge_with_meta_vertex( t, dgreen_vertex,
                                          w, o, G, W, L);
    }//I D/D+A
    
    if(C[s]+C[t] == 4){
        //add edge between white and lgreen
        make_update_edge_with_meta_vertex( s, lgreen_vertex,
                                          w, o, G, W, L);
        //add edge between grey and lgreen
        make_update_edge_with_meta_vertex( t, lgreen_vertex,
                                          w, o, G, W, L);
    }//I A/D+A
    
    
    if(C[s]+C[t] == 12){
        //add edge between orange and purple
        make_update_edge_with_meta_vertex( s, purple_vertex,
                                          w, o, G, W, L);
        //add edge between yellow and purple
        make_update_edge_with_meta_vertex( t, purple_vertex,
                                          w, o, G, W, L);
    }//I Dcr/Acr
    
    if(C[s]+C[t] == 6){
        //add edge between orange and dpink
        make_update_edge_with_meta_vertex( s, dpink_vertex,
                                          w, o, G, W, L);
        //add edge between white and dpink
        make_update_edge_with_meta_vertex( t, dpink_vertex,
                                          w, o, G, W, L);
    }//I Dcr/Aam
    
    
    if(( (C[s] == ORANGE) && (C[t]==GREY))
       ||
       ( (C[s] == GREY)   && (C[t]==ORANGE))
       ){
        //add edge between orange and ddpink
        make_update_edge_with_meta_vertex( s, ddpink_vertex,
                                          w, o, G, W, L);
        //add edge between grey and ddpink
        make_update_edge_with_meta_vertex( t, ddpink_vertex,
                                          w, o, G, W, L);
    }//I Dcr/M
    
    if(C[s]+C[t] == 5){
        //add edge between orange and dddpink
        make_update_edge_with_meta_vertex( s, dddpink_vertex,
                                          w, o, G, W, L);
        //add edge between black and ddpink
        make_update_edge_with_meta_vertex( t, dddpink_vertex,
                                          w, o, G, W, L);
    }//I Dcr/Dam
    
    if(C[s]+C[t] == 7){
        //add edge between yellow and lpink
        make_update_edge_with_meta_vertex( s, lpink_vertex,
                                          w, o, G, W, L);
        //add edge between black and lpink
        make_update_edge_with_meta_vertex( t, lpink_vertex,
                                          w, o, G, W, L);
    }//I Acr/Dam
    
    if(C[s]+C[t] == 10){
        //add edge between yellow and llpink
        make_update_edge_with_meta_vertex( s, llpink_vertex,
                                          w, o, G, W, L);
        //add edge between grey and llpink
        make_update_edge_with_meta_vertex( t, llpink_vertex,
                                          w, o, G, W, L);
    }//I Acr/M
    
    if ( ((C[s]==WHITE) && (C[t]==YELLOW))
         ||
        ((C[s]==YELLOW) && (C[t]==WHITE))
        ){
        //add edge between yellow and lllpink
        make_update_edge_with_meta_vertex( s, lllpink_vertex,
                                          w, o, G, W, L);
        //add edge between white and lllpink
        make_update_edge_with_meta_vertex( t, lllpink_vertex,
                                          w, o, G, W, L);
    }//I Acr/Aam
}

void graspi::make_update_edge_with_meta_vertex( int s, int meta_t,
                                               double w, char o,
                                               graph_t* G,
                                               edge_weights_t& W,
                                               edge_colors_t& L)
{
    
    //add edges between source and target_metavertex
    graspi::edge_descriptor_t e;
    bool e_res = false;
    boost::tie(e, e_res) = boost::edge(s, meta_t, *G);
    if (e_res == false) {
        std::pair<int,int> p = std::pair<int,int>(std::min(s,meta_t),
                                                  std::max(s,meta_t));
        boost::tie(e, e_res) = boost::add_edge(s, meta_t, *G);
        W[e] = w/2.0;
        L[p]=o;
    }else{ // if edge exist check if current distance is shorter
        // and change accordingly
        float existing_distance = boost::get(W, e);
        if( (w/2.0) < existing_distance){
            std::pair<int,int> p = std::pair<int,int>(std::min(s,meta_t),
                                                      std::max(s,meta_t));
            W[e] = w/2.0;
            L[p] = o;
        }
    }
}


// determine the position in row-wise array on the basis of index i_x and i_y
int graspi::compute_pos_2D(int i_x, int i_y,
                           const dim_a_t& d_a,
                           bool if_per_on_sides){
    
    if( i_y == -1)    return -1;
    if( i_y == d_a.ny )  return -2;
    
    if (if_per_on_sides){
        if ( i_x == -1 )     i_x = d_a.nx-1;
        if ( i_x == d_a.nx ) i_x = 0;
    }else{
        if( ( i_x == -1 ) || (i_x == d_a.nx) ) return -3;
    }
    
    return i_x + d_a.nx * i_y ;
}


// determine the position in row-wise array on the basis of index i_x and i_y
int graspi::compute_pos_3D(int i_x, int i_y, int i_z,
                           const dim_a_t& d_a,
                           bool if_per_on_sides){
    
    if( i_z == -1)    return -1;
    if( i_z == d_a.nz )  return -2;
    
    if (if_per_on_sides){
        if ( i_x == -1 )     i_x = d_a.nx-1;
        if ( i_x == d_a.nx ) i_x = 0;
        if ( i_y == -1 )     i_y = d_a.ny-1;
        if ( i_y == d_a.ny ) i_y = 0;
    }else{
        if(
           ( i_x == -1 ) || ( i_x == d_a.nx )
           ||
           ( i_y == -1 ) || ( i_y == d_a.ny )
           )
            return -3;
    }
    
    return i_x + d_a.nx * (i_y + d_a.ny * i_z) ;
}


// generate 2D neighborhood for 2D case
void graspi::generate_ngbr(int i, int j, int k,
                           const dim_a_t& d_a,
                           std::pair<int,char>* ngbr,
                           bool if_per_on_sides ){
    // 2D
    if( (d_a.nz == 0) || (d_a.nz == 1) ) {
        k = 0;
        ngbr[0].first = compute_pos_2D(i  ,j+1, d_a, if_per_on_sides);	// ngbr N
        ngbr[1].first = compute_pos_2D(i+1,j+1, d_a, if_per_on_sides);	// ngbr NE
        ngbr[2].first = compute_pos_2D(i+1,j  , d_a, if_per_on_sides);	// ngbr E
        ngbr[3].first = compute_pos_2D(i+1,j-1, d_a, if_per_on_sides);	// ngbr ES
        ngbr[4].first = compute_pos_2D(i  ,j-1, d_a, if_per_on_sides);	// ngbr S
        ngbr[5].first = compute_pos_2D(i-1,j-1, d_a, if_per_on_sides);	// ngbr SW
        ngbr[6].first = compute_pos_2D(i-1,j  , d_a, if_per_on_sides);	// ngbr W
        ngbr[7].first = compute_pos_2D(i-1,j+1, d_a, if_per_on_sides);	// ngbr WN
        
        ngbr[0].second = 'f'; // ngbr N
        ngbr[1].second = 's'; // ngbr NE
        ngbr[2].second = 'f'; // ngbr E
        ngbr[3].second = 's'; // ngbr ES
        ngbr[4].second = 'f'; // ngbr S
        ngbr[5].second = 's'; // ngbr SW
        ngbr[6].second = 'f'; // ngbr W
        ngbr[7].second = 's'; // ngbr WN
    }else{// 3D
        ngbr[0].first = compute_pos_3D(i  ,j+1, k, d_a, if_per_on_sides);	// ngbr N
        ngbr[1].first = compute_pos_3D(i+1,j+1, k, d_a, if_per_on_sides);	// ngbr NE
        ngbr[2].first = compute_pos_3D(i+1,j  , k, d_a, if_per_on_sides);	// ngbr E
        ngbr[3].first = compute_pos_3D(i+1,j-1, k, d_a, if_per_on_sides);	// ngbr ES
        ngbr[4].first = compute_pos_3D(i  ,j-1, k, d_a, if_per_on_sides);	// ngbr S
        ngbr[5].first = compute_pos_3D(i-1,j-1, k, d_a, if_per_on_sides);	// ngbr SW
        ngbr[6].first = compute_pos_3D(i-1,j  , k, d_a, if_per_on_sides);	// ngbr W
        ngbr[7].first = compute_pos_3D(i-1,j+1, k, d_a, if_per_on_sides);	// ngbr WN
        
        ngbr[0].second = 'f'; // ngbr N
        ngbr[1].second = 's'; // ngbr NE
        ngbr[2].second = 'f'; // ngbr E
        ngbr[3].second = 's'; // ngbr ES
        ngbr[4].second = 'f'; // ngbr S
        ngbr[5].second = 's'; // ngbr SW
        ngbr[6].second = 'f'; // ngbr W
        ngbr[7].second = 's'; // ngbr WN
        
        ngbr[8].first  = compute_pos_3D(i  ,j+1, k+1, d_a, if_per_on_sides);	// ngbr N
        ngbr[9].first  = compute_pos_3D(i+1,j+1, k+1, d_a, if_per_on_sides);	// ngbr NE
        ngbr[10].first = compute_pos_3D(i+1,j  , k+1, d_a, if_per_on_sides);	// ngbr E
        ngbr[11].first = compute_pos_3D(i+1,j-1, k+1, d_a, if_per_on_sides);	// ngbr ES
        ngbr[12].first = compute_pos_3D(i  ,j-1, k+1, d_a, if_per_on_sides);	// ngbr S
        ngbr[13].first = compute_pos_3D(i-1,j-1, k+1, d_a, if_per_on_sides);	// ngbr SW
        ngbr[14].first = compute_pos_3D(i-1,j  , k+1, d_a, if_per_on_sides);	// ngbr W
        ngbr[15].first = compute_pos_3D(i-1,j+1, k+1, d_a, if_per_on_sides);	// ngbr WN
        ngbr[16].first = compute_pos_3D(i,j,     k+1, d_a, if_per_on_sides);	// ngbr WN
        
        ngbr[8].second  = 's'; // ngbr N
        ngbr[9].second  = 't'; // ngbr NE
        ngbr[10].second = 's'; // ngbr E
        ngbr[11].second = 't'; // ngbr ES
        ngbr[12].second = 's'; // ngbr S
        ngbr[13].second = 't'; // ngbr SW
        ngbr[14].second = 's'; // ngbr W
        ngbr[15].second = 't'; // ngbr WN
        ngbr[16].second = 'f'; // ngbr WN
        
        ngbr[17].first = compute_pos_3D(i  ,j+1, k-1, d_a, if_per_on_sides);	// ngbr N
        ngbr[18].first = compute_pos_3D(i+1,j+1, k-1, d_a, if_per_on_sides);	// ngbr NE
        ngbr[19].first = compute_pos_3D(i+1,j  , k-1, d_a, if_per_on_sides);	// ngbr E
        ngbr[20].first = compute_pos_3D(i+1,j-1, k-1, d_a, if_per_on_sides);	// ngbr ES
        ngbr[21].first = compute_pos_3D(i  ,j-1, k-1, d_a, if_per_on_sides);	// ngbr S
        ngbr[22].first = compute_pos_3D(i-1,j-1, k-1, d_a, if_per_on_sides);	// ngbr SW
        ngbr[23].first = compute_pos_3D(i-1,j  , k-1, d_a, if_per_on_sides);	// ngbr W
        ngbr[24].first = compute_pos_3D(i-1,j+1, k-1, d_a, if_per_on_sides);	// ngbr WN
        ngbr[25].first = compute_pos_3D(i,j,     k-1, d_a, if_per_on_sides);	// ngbr WN
        
        ngbr[17].second = 's'; // ngbr N
        ngbr[18].second = 't'; // ngbr NE
        ngbr[19].second = 's'; // ngbr E
        ngbr[20].second = 't'; // ngbr ES
        ngbr[21].second = 's'; // ngbr S
        ngbr[22].second = 't'; // ngbr SW
        ngbr[23].second = 's'; // ngbr W
        ngbr[24].second = 't'; // ngbr WN
        ngbr[25].second = 'f'; // ngbr WN
        
    }
    
}

