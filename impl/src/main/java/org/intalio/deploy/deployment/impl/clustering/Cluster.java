package org.intalio.deploy.deployment.impl.clustering;

import java.io.Serializable;
import java.util.List;

/**
 * This class represents the view of the cluster from a node's perspective. Any actions on the physical cluster is delegated
 * through this class.
 * 
 * @author sean
 *
 */
public interface Cluster {
    /**
     * Returns the identifier of this node in the cluster.
     * 
     * @return the id of this node
     */
    String getServerId();
    
    /**
     * Initiates joining of this node to the cluster. This call blocks until the cluster is conformed. If a quorum based clustering
     * is used, the number of joined nodes in the cluster should be bigger than floor(cluster size / 2), for this call to return.
     */
    void start();
    
    /**
     * Initiates leaving of this node from the cluster. This call returns immediately.
     */
    void shutdown();
    
    /**
     * Sends a message to all nodes in the cluster including this node itself.
     * 
     * @param obj
     */
    void sendMessage(Serializable obj);

    /**
     * Returns true if this node is the coordinator in the node. If in a quorum based clustering, the quorum number should be
     * satisfied for a coordinator to be elected.
     * 
     * @return true if this node is the coordinator
     */
    boolean isCoordinator();
    
    void warmUp();

    /**
     * Returns all the current members in the cluster.
     * 
     * @return a list of strings each of which represents a member node's identifier
     */
    List<String> getCurrentMembers();

    /**
     * Returns the cluster listener that's listening on this cluster.
     * 
     * @return the cluster listener
     */
    public ClusterListener getListener();

    /**
     * Sets the cluster listener.
     * 
     * @param listener the cluster listener
     */
    public void setListener(ClusterListener listener);

    /**
     * Returns the group name of the cluster.
     * 
     * @return the group name
     */
    public String getGroupName();

    /**
     * Sets the group name of the cluster.
     * 
     * @param groupName thr group name
     */
    public void setGroupName(String groupName);
}
