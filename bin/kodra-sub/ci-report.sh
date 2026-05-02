#!/usr/bin/env bash
#
# ci-report.sh — Pull CI logs and generate remediation reports
#
# Usage:
#   kodra ci-report              # Latest run (auto-detects failed)
#   kodra ci-report --run ID     # Specific run
#   kodra ci-report --watch      # Watch current run, report on completion
#   kodra ci-report --history 5  # Last 5 runs summary
#
# Output: Markdown remediation report to stdout + .kodra/ci-reports/
#
# Requires: gh CLI authenticated
#

set -e

# ── Config ──
REPO="${KODRA_CI_REPO:-codetocloudorg/kodra}"
REPORT_DIR="${KODRA_DIR:-$HOME/.kodra}/ci-reports"
MAX_LOG_LINES=500

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Functions ──

# Display usage information and available CLI options
show_help() {
    echo "Usage: kodra ci-report [OPTIONS]"
    echo ""
    echo "Pull CI/CD logs from GitHub Actions and generate remediation reports."
    echo ""
    echo "Options:"
    echo "  --run ID       Analyze a specific workflow run"
    echo "  --watch        Watch the latest in-progress run, report on completion"
    echo "  --history N    Show summary of last N runs (default: 10)"
    echo "  --failed-only  Only show failed jobs (default for single run)"
    echo "  --all-logs     Include all job logs, not just failures"
    echo "  --json         Output as JSON instead of markdown"
    echo "  -h, --help     Show this help"
    echo ""
    echo "Reports are saved to: $REPORT_DIR/"
}

# Verify gh CLI is installed and authenticated
check_deps() {
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}Error: gh CLI not found. Install: https://cli.github.com${NC}" >&2
        exit 1
    fi
    if ! gh auth status &>/dev/null 2>&1; then
        echo -e "${RED}Error: gh CLI not authenticated. Run: gh auth login${NC}" >&2
        exit 1
    fi
}

# Get the most recent workflow run ID from the repository
# Arguments:
#   $1 - Optional status filter (e.g., "in_progress")
get_latest_run() {
    local status="${1:-}"
    local filter=""
    if [ -n "$status" ]; then
        filter="--json databaseId,status,conclusion,name -q '.[] | select(.status==\"$status\") | .databaseId' | head -1"
    fi
    gh run list --repo "$REPO" --limit 1 --json databaseId,status,conclusion \
        --jq '.[0].databaseId'
}

# Get the most recent failed run ID from the last 10 runs
get_latest_failed_run() {
    gh run list --repo "$REPO" --limit 10 --json databaseId,status,conclusion \
        --jq '[.[] | select(.conclusion=="failure")][0].databaseId'
}

# Block until an in-progress run completes, then generate its report
watch_run() {
    local run_id
    run_id=$(gh run list --repo "$REPO" --limit 1 \
        --json databaseId,status --jq '[.[] | select(.status=="in_progress" or .status=="queued")][0].databaseId')

    if [ -z "$run_id" ] || [ "$run_id" = "null" ]; then
        echo -e "${YELLOW}No in-progress runs. Checking latest...${NC}"
        run_id=$(get_latest_run)
    fi

    echo -e "${BLUE}⏳ Watching run ${run_id}...${NC}"
    gh run watch "$run_id" --repo "$REPO" --exit-status 2>/dev/null || true
    echo ""
    analyze_run "$run_id"
}

# Fetch run metadata, pull logs for failed jobs, and write a markdown report
# Arguments:
#   $1 - Workflow run ID
#   $2 - Include all logs, not just failures ("true"/"false")
#   $3 - Output as JSON instead of markdown ("true"/"false")
analyze_run() {
    local run_id="$1"
    local all_logs="${2:-false}"
    local output_json="${3:-false}"

    mkdir -p "$REPORT_DIR"
    local report_file="$REPORT_DIR/run-${run_id}-$(date +%Y%m%d-%H%M%S).md"

    # Get run metadata
    local run_data
    run_data=$(gh run view "$run_id" --repo "$REPO" --json \
        name,status,conclusion,startedAt,updatedAt,headBranch,event,jobs,url 2>/dev/null)

    local run_name run_conclusion run_url run_branch run_event
    run_name=$(echo "$run_data" | jq -r '.name')
    run_conclusion=$(echo "$run_data" | jq -r '.conclusion')
    run_url=$(echo "$run_data" | jq -r '.url')
    run_branch=$(echo "$run_data" | jq -r '.headBranch')
    run_event=$(echo "$run_data" | jq -r '.event')

    # Start report
    {
        echo "# CI Remediation Report"
        echo ""
        echo "| Field | Value |"
        echo "|-------|-------|"
        echo "| **Run** | [#${run_id}](${run_url}) |"
        echo "| **Workflow** | ${run_name} |"
        echo "| **Branch** | ${run_branch} |"
        echo "| **Event** | ${run_event} |"
        echo "| **Result** | ${run_conclusion} |"
        echo "| **Generated** | $(date -Iseconds) |"
        echo ""
    } > "$report_file"

    # Get job results
    local jobs
    jobs=$(echo "$run_data" | jq -c '.jobs[]')

    local failed_jobs=0
    local total_jobs=0
    local remediation_items=""

    echo -e "${BLUE}━━━ CI Report: Run #${run_id} (${run_conclusion}) ━━━${NC}"
    echo ""

    while IFS= read -r job; do
        total_jobs=$((total_jobs + 1))
        local job_name job_conclusion job_id
        job_name=$(echo "$job" | jq -r '.name')
        job_conclusion=$(echo "$job" | jq -r '.conclusion')
        job_id=$(echo "$job" | jq -r '.databaseId')

        local icon="✅"
        if [ "$job_conclusion" = "failure" ]; then
            icon="❌"
            failed_jobs=$((failed_jobs + 1))
        elif [ "$job_conclusion" = "skipped" ]; then
            icon="⏭️"
        fi

        echo -e "  ${icon} ${job_name} — ${job_conclusion}"

        # Pull logs for failed jobs (or all if requested)
        if [ "$job_conclusion" = "failure" ] || [ "$all_logs" = "true" ]; then
            {
                echo "## ${icon} ${job_name}"
                echo ""
                echo "**Status**: ${job_conclusion}"
                echo ""
            } >> "$report_file"

            # Get job logs
            local log_content
            log_content=$(gh api "repos/${REPO}/actions/jobs/${job_id}/logs" 2>/dev/null | tail -"$MAX_LOG_LINES" || echo "Could not retrieve logs")

            # Extract error lines using common CI failure patterns
            local errors
            errors=$(echo "$log_content" | grep -i "error\|::error\|FAILED\|not ok\|exit code [1-9]" | head -30 || true)

            if [ -n "$errors" ]; then
                {
                    echo "### 🚨 Errors Found"
                    echo ""
                    echo '```'
                    echo "$errors"
                    echo '```'
                    echo ""
                } >> "$report_file"

                # Generate remediation suggestions
                local remediations
                remediations=$(generate_remediation "$errors" "$job_name")
                if [ -n "$remediations" ]; then
                    {
                        echo "### 🔧 Remediation Steps"
                        echo ""
                        echo "$remediations"
                        echo ""
                    } >> "$report_file"
                    remediation_items="${remediation_items}${remediations}\n"
                fi
            fi

            # Include tail of logs
            {
                echo "<details><summary>Full logs (last ${MAX_LOG_LINES} lines)</summary>"
                echo ""
                echo '```'
                echo "$log_content" | tail -100
                echo '```'
                echo "</details>"
                echo ""
            } >> "$report_file"
        fi
    done <<< "$jobs"

    # Summary section
    {
        echo "---"
        echo ""
        echo "## 📊 Summary"
        echo ""
        echo "- **Total jobs**: ${total_jobs}"
        echo "- **Failed**: ${failed_jobs}"
        echo "- **Passed**: $((total_jobs - failed_jobs))"
        echo ""
        if [ -n "$remediation_items" ]; then
            echo "## 📋 Remediation Checklist"
            echo ""
            echo -e "$remediation_items"
        fi
    } >> "$report_file"

    echo ""
    echo -e "${CYAN}📄 Report saved: ${report_file}${NC}"
    echo ""

    if [ "$failed_jobs" -gt 0 ]; then
        echo -e "${RED}⚠️  ${failed_jobs} job(s) need remediation${NC}"
        echo ""
        echo -e "${YELLOW}Remediation items:${NC}"
        echo -e "$remediation_items" | head -20
    else
        echo -e "${GREEN}✅ All jobs passed — no remediation needed${NC}"
    fi
}

# Map error patterns to actionable remediation checklist items
# Arguments:
#   $1 - Error log text to scan for known failure patterns
#   $2 - Job name (used in fallback message)
generate_remediation() {
    local errors="$1"
    local job_name="$2"
    local items=""

    # Pattern matching for common CI failures
    if echo "$errors" | grep -qi "syntax error"; then
        items="${items}- [ ] **Syntax error**: Fix shell syntax — check \`bash -n\` on the affected script\n"
    fi

    if echo "$errors" | grep -qi "shellcheck"; then
        items="${items}- [ ] **ShellCheck**: Fix lint warnings — run \`shellcheck --severity=warning\` locally\n"
    fi

    if echo "$errors" | grep -qi "permission denied"; then
        items="${items}- [ ] **Permissions**: Ensure scripts are executable — \`chmod +x\`\n"
    fi

    if echo "$errors" | grep -qi "command not found\|not found"; then
        items="${items}- [ ] **Missing command**: Install missing dependency or check PATH\n"
    fi

    if echo "$errors" | grep -qi "not ok.*security\|HTTPS\|secret\|setuid"; then
        items="${items}- [ ] **Security test failure**: Review security test output — may need allowlist update\n"
    fi

    if echo "$errors" | grep -qi "not ok.*unit\|not ok.*integration"; then
        items="${items}- [ ] **Test failure**: Run \`bats tests/\` locally to reproduce\n"
    fi

    if echo "$errors" | grep -qi "docker\|buildx\|image"; then
        items="${items}- [ ] **Docker build**: Check Dockerfile changes — run \`docker build .\` locally\n"
    fi

    if echo "$errors" | grep -qi "timeout\|timed out"; then
        items="${items}- [ ] **Timeout**: Job exceeded time limit — optimize or split the step\n"
    fi

    if echo "$errors" | grep -qi "apt-get\|dpkg\|package"; then
        items="${items}- [ ] **Package install**: Check package name/availability for the target Ubuntu version\n"
    fi

    if echo "$errors" | grep -qi "version\|VERSION"; then
        items="${items}- [ ] **Version mismatch**: Ensure VERSION file matches README, index.html, CHANGELOG\n"
    fi

    if [ -z "$items" ]; then
        items="- [ ] **Unknown failure in ${job_name}**: Review logs manually\n"
    fi

    echo -e "$items"
}

# Display a tabular summary of the last N workflow runs
# Arguments:
#   $1 - Number of runs to show (default: 10)
show_history() {
    local count="${1:-10}"
    echo -e "${BLUE}━━━ Last ${count} CI Runs ━━━${NC}"
    echo ""
    printf "%-12s %-10s %-40s %-15s %s\n" "RUN ID" "RESULT" "WORKFLOW" "BRANCH" "AGE"
    printf "%-12s %-10s %-40s %-15s %s\n" "──────" "──────" "────────" "──────" "───"

    gh run list --repo "$REPO" --limit "$count" \
        --json databaseId,conclusion,name,headBranch,updatedAt \
        --jq '.[] | [.databaseId, .conclusion, .name, .headBranch, .updatedAt] | @tsv' | \
    while IFS=$'\t' read -r id conclusion name branch updated; do
        local icon="✅"
        [ "$conclusion" = "failure" ] && icon="❌"
        [ "$conclusion" = "cancelled" ] && icon="⏹️"
        [ "$conclusion" = "" ] && icon="🔄"
        printf "%-12s %s %-8s %-40s %-15s %s\n" "$id" "$icon" "$conclusion" "$name" "$branch" "$updated"
    done
}

# ── Main ──

# Parse CLI flags and dispatch to the appropriate action
main() {
    check_deps

    local run_id=""
    local watch=false
    local history=0
    local all_logs=false
    local output_json=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --run) run_id="$2"; shift 2 ;;
            --watch) watch=true; shift ;;
            --history) history="${2:-10}"; shift 2 ;;
            --all-logs) all_logs=true; shift ;;
            --failed-only) all_logs=false; shift ;;
            --json) output_json=true; shift ;;
            -h|--help) show_help; exit 0 ;;
            *) echo "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done

    if [ "$watch" = "true" ]; then
        watch_run
    elif [ "$history" -gt 0 ]; then
        show_history "$history"
    else
        if [ -z "$run_id" ]; then
            run_id=$(get_latest_failed_run)
            if [ -z "$run_id" ] || [ "$run_id" = "null" ]; then
                run_id=$(get_latest_run)
            fi
        fi
        analyze_run "$run_id" "$all_logs" "$output_json"
    fi
}

main "$@"
