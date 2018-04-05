package verigames.level;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import verigames.utilities.Misc;

public class ChuteNormalizer {

    private Set<Chute> inputChutes;
    private Map<Integer, Boolean> widths;
    private Map<Integer, ForcedWidths> widthsInfo;
    private List<Integer> knownSubtypes;
    private boolean parseMode;

    public ChuteNormalizer( Set<Chute> inputChutes, List<Integer> knownSubtypes ) {
        this.inputChutes = inputChutes;
        this.knownSubtypes = knownSubtypes;
    }
    
    public ChuteNormalizer( Set<Chute> inputChutes, boolean parseMode ) {
        this.inputChutes = inputChutes;
        this.parseMode = parseMode;
    }
    
    private void processChutes() {
        final Map<Integer, ForcedWidths> processingWidths = new LinkedHashMap<Integer, ForcedWidths>();

        for( final Chute chute : inputChutes ) {
            int varID = chute.getVariableID();

            if( varID >= 0 )  {
                // if this variableID is already in the mapping, just check that it's
                // not contradictory
                final ForcedWidths width;
                if ( processingWidths.containsKey(varID) ) {
                    width = processingWidths.get( varID );
                }
                // else, add it to the mapping
                else {
                    width = new ForcedWidths( varID );
                    processingWidths.put( varID, width );
                }

                width.addChute( chute );
            }
        }

        boolean conflicted = false;
        boolean forceConflicted = false;
        for( final Map.Entry<Integer, ForcedWidths> idToFw : processingWidths.entrySet() ) {
            if( idToFw.getValue().isWidthConflicted() ) {
                conflicted = true;
                System.out.println( idToFw.getValue() );
                forceConflicted = idToFw.getValue().isForceConflicted();
            }
        }
        
        if( Misc.CHECK_REP_STRICT && parseMode && conflicted ) {
            // Parse mode is more strict because we don't expect to get any linked chutes back with different id's.
            
            throw new RuntimeException( "There are variables with conflictingWidths." );
        } else if( Misc.CHECK_REP_STRICT && forceConflicted ) {
            throw new RuntimeException( "There are variables with conflictingWidths." );
        }

        final Map<Integer, Boolean> idToWidth = new HashMap<Integer, Boolean>();
        for( final Map.Entry<Integer, ForcedWidths> idToFw : processingWidths.entrySet() ) {
            idToWidth.put( idToFw.getKey(), idToFw.getValue().isNarrow() );
        }

        widthsInfo = processingWidths;
        widths = idToWidth;
    }
    
    public void normalizeChutes() {
        processChutes();
        for( Chute chute : inputChutes ) {
            ForcedWidths width = widthsInfo.get(chute.getVariableID());
            if (width != null) {
                chute.setNarrow(width.isNarrow());
                chute.setEditable(! width.isUneditable());
            }
        }
    }

    public Map<Integer, Boolean> getWidths() {
        return widths;
    }

    /**
     * A class for keeping track of whether or not for a single variable there are conflicts between
     * chutes that represent that variable.
     */
    class ForcedWidths {

        /**
         * Variable id for this width
         */
        private final int id;

        /**
         * Does the given variable have an EDITABLE chute that is wide
         */
        private boolean wide;

        /**
         * Does the given variable have an editable chute that is narrow
         */
        private boolean narrow;


        /**
         * Does the given variable have an UNEDITABLE chute that is wide
         */
        private boolean forcedNarrow;

        /**
         * Does the given variable have an UNEDITABLE chute that is narrow
         */
        private boolean forcedWide;

        public ForcedWidths( final int id ) {
            this.id = id;
            forcedNarrow = false;
            forcedWide   = false;
            wide   = false;
            narrow = false;
        }

        /**
         * Whether there is a conflict between UNEDITABLE chutes
         * @return
         */
        public boolean isForceConflicted() {
            return forcedNarrow && forcedWide;
        }

        /**
         * Whether there is a conflict between EDITABLE chutes
         * @return
         */
        private boolean isConflicted() {
            return wide && narrow;
        }

        /**
         * Whether there are ANY conflicts between editable/uneditable widths
         * @return
         */
        private boolean isWidthConflicted() {
            return ( wide && forcedNarrow ) || ( narrow && forcedWide ) || isForceConflicted() || isConflicted();
        }
        
        private boolean isUneditable() {
            return ( forcedNarrow || forcedWide );
        }

        /**
         * Return the preferred width even if there are conflicts.
         * @return
         */
        public boolean isNarrow() {
            final boolean isNarrow;
            if( knownSubtypes != null ) {
            	if ( isForceConflicted() ) {
            		isNarrow = false; // TODO: Type system dependent
            	} else if( forcedWide ) {
            		isNarrow = false;
            	} else if( forcedNarrow ) {
            		isNarrow = true;
            	} else if( knownSubtypes.contains(id) ) {
            		isNarrow = true;
            	} else {
            		isNarrow = false;
            	}
            } else {
	            if( isForceConflicted() ) {
	                isNarrow = false;  // TODO: Type system dependent
	            } else if( isConflicted() ) {
	                isNarrow = false;  // TODO: Type system dependent
	            } else if( forcedWide ) {
                    isNarrow = false;
                } else if( forcedNarrow ) {
                    isNarrow = true;
                } else {
                	isNarrow = narrow;
	            }
            }
            
            return isNarrow;
        }

        /**
         * Update this ForcedWidth with the information from the given chute.
         * @param chute
         */
        public void addChute( final Chute chute ) {
            if( chute.isEditable() ) {
                if( chute.isNarrow() ) {
                    narrow = true;
                } else {
                    wide = true;
                }
            } else {
                if( chute.isNarrow() ) {
                    forcedNarrow = true;
                } else {
                    forcedWide = true;
                }
            }
        }

        @Override
        public String toString() {
            return ( isWidthConflicted() ? "Conflicted " : "" ) +
                    "ForcedWidths( id=" + id + " narrow=" + narrow + " wide=" + wide +
                    " forcedNarrow=" + forcedNarrow + " forcedWide=" + forcedWide + " )";
        }
    }
}
