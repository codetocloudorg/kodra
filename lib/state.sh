#!/usr/bin/env bash
#
# Kodra State Management
# Track installation progress for resume capability
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
KODRA_STATE_FILE="$KODRA_CONFIG_DIR/state.json"

# Source utils for logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
fi

# Initialize state file
init_state() {
    mkdir -p "$KODRA_CONFIG_DIR"
    
    if [ ! -f "$KODRA_STATE_FILE" ]; then
        cat > "$KODRA_STATE_FILE" << 'EOF'
{
  "version": "0.2.0",
  "install_started": null,
  "install_completed": null,
  "components": {},
  "failed": [],
  "theme": null,
  "container_runtime": null
}
EOF
    fi
}

# Read state value using simple parsing (no jq dependency)
# Args: $1 = key
get_state() {
    local key="$1"
    
    if [ ! -f "$KODRA_STATE_FILE" ]; then
        echo ""
        return
    fi
    
    grep "\"$key\":" "$KODRA_STATE_FILE" | sed 's/.*": *"\?\([^",}]*\)"\?.*/\1/' | tr -d ' '
}

# Update state file
# Args: $1 = key, $2 = value
set_state() {
    local key="$1"
    local value="$2"
    
    init_state
    
    # Simple sed-based update (works without jq)
    if grep -q "\"$key\":" "$KODRA_STATE_FILE"; then
        sed -i "s/\"$key\": *[^,}]*/\"$key\": \"$value\"/" "$KODRA_STATE_FILE"
    fi
}

# Mark component as installed
# Args: $1 = component name
mark_installed() {
    local component="$1"
    local timestamp=$(date -Iseconds)
    
    init_state
    
    # Add to installed components
    if command -v jq &> /dev/null; then
        jq ".components[\"$component\"] = \"$timestamp\"" "$KODRA_STATE_FILE" > "$KODRA_STATE_FILE.tmp"
        mv "$KODRA_STATE_FILE.tmp" "$KODRA_STATE_FILE"
    else
        # Fallback: append to simple log
        echo "$timestamp:installed:$component" >> "$KODRA_CONFIG_DIR/install.log"
    fi
}

# Mark component as failed
# Args: $1 = component name, $2 = error message
mark_failed() {
    local component="$1"
    local error="${2:-unknown error}"
    local timestamp=$(date -Iseconds)
    
    init_state
    
    if command -v jq &> /dev/null; then
        jq ".failed += [{\"component\": \"$component\", \"error\": \"$error\", \"timestamp\": \"$timestamp\"}]" "$KODRA_STATE_FILE" > "$KODRA_STATE_FILE.tmp"
        mv "$KODRA_STATE_FILE.tmp" "$KODRA_STATE_FILE"
    else
        # Fallback: append to simple log
        echo "$timestamp:failed:$component:$error" >> "$KODRA_CONFIG_DIR/install.log"
    fi
}

# Check if component is installed
# Args: $1 = component name
is_installed() {
    local component="$1"
    
    if [ ! -f "$KODRA_STATE_FILE" ]; then
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        jq -e ".components[\"$component\"]" "$KODRA_STATE_FILE" &> /dev/null
    else
        grep -q ":installed:$component" "$KODRA_CONFIG_DIR/install.log" 2>/dev/null
    fi
}

# Get list of failed components
get_failed_components() {
    if [ ! -f "$KODRA_STATE_FILE" ]; then
        return
    fi
    
    if command -v jq &> /dev/null; then
        jq -r '.failed[].component' "$KODRA_STATE_FILE" 2>/dev/null
    else
        grep ":failed:" "$KODRA_CONFIG_DIR/install.log" 2>/dev/null | cut -d: -f3
    fi
}

# Get list of installed components
get_installed_components() {
    if [ ! -f "$KODRA_STATE_FILE" ]; then
        return
    fi
    
    if command -v jq &> /dev/null; then
        jq -r '.components | keys[]' "$KODRA_STATE_FILE" 2>/dev/null
    else
        grep ":installed:" "$KODRA_CONFIG_DIR/install.log" 2>/dev/null | cut -d: -f3
    fi
}

# Mark installation started
mark_install_started() {
    init_state
    set_state "install_started" "$(date -Iseconds)"
    set_state "install_completed" "null"
}

# Mark installation completed
mark_install_completed() {
    set_state "install_completed" "$(date -Iseconds)"
}

# Check if there's an incomplete installation
has_incomplete_install() {
    local started=$(get_state "install_started")
    local completed=$(get_state "install_completed")
    
    [ -n "$started" ] && [ "$completed" = "null" -o -z "$completed" ]
}

# Show installation status
show_install_status() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ ! -f "$KODRA_STATE_FILE" ] && [ ! -f "$KODRA_CONFIG_DIR/install.log" ]; then
        echo "No installation state found."
        return
    fi
    
    local started=$(get_state "install_started")
    local completed=$(get_state "install_completed")
    
    if [ -n "$started" ]; then
        echo "Started: $started"
    fi
    
    if [ -n "$completed" ] && [ "$completed" != "null" ]; then
        echo "Completed: $completed"
        echo ""
        log_success "Installation completed successfully"
    elif [ -n "$started" ]; then
        echo "Status: INCOMPLETE"
        echo ""
        log_warning "Installation did not complete"
    fi
    
    # Show installed components
    local installed=$(get_installed_components)
    if [ -n "$installed" ]; then
        echo ""
        echo "Installed components:"
        echo "$installed" | while read comp; do
            echo "  ✅ $comp"
        done
    fi
    
    # Show failed components
    local failed=$(get_failed_components)
    if [ -n "$failed" ]; then
        echo ""
        echo "Failed components:"
        echo "$failed" | while read comp; do
            echo "  ❌ $comp"
        done
    fi
    
    echo ""
}

# Clear installation state (for fresh start)
clear_state() {
    rm -f "$KODRA_STATE_FILE"
    rm -f "$KODRA_CONFIG_DIR/install.log"
    log_info "Installation state cleared"
}
