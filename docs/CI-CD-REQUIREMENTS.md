# CI/CD Requirements for vantisCorp/OBS

## Current Status

This repository is **private** and owned by a **user account** (not an organization).

## GitHub Actions Requirements

For private repositories, GitHub Actions requires one of the following:

| Plan | Actions Minutes | Storage |
|------|----------------|---------|
| GitHub Free | ❌ Not available | ❌ Not available |
| GitHub Pro | 3,000 minutes/month | 2GB |
| GitHub Team | 3,000 minutes/month | 2GB |
| GitHub Enterprise | 50,000 minutes/month | 50GB |

## Current Issue

All workflow runs are failing with:
- `runner_id: 0`
- `steps: []`
- Duration: 2-8 seconds

This indicates the runner cannot be allocated due to billing restrictions.

## Solutions

### Option 1: Upgrade GitHub Plan
Upgrade to GitHub Pro or Team to get Actions minutes for private repositories.

**Steps:**
1. Go to GitHub Settings → Billing
2. Upgrade to GitHub Pro or Team
3. Actions will automatically work

### Option 2: Make Repository Public
Public repositories get free GitHub Actions.

**Steps:**
1. Go to Repository Settings
2. Scroll to "Danger Zone"
3. Click "Change visibility"
4. Select "Make public"

**Warning:** This will make all code publicly accessible.

### Option 3: Self-Hosted Runners
Add your own runners to execute workflows.

**Steps:**
1. Go to Repository Settings → Actions → Runners
2. Click "New self-hosted runner"
3. Follow the setup instructions
4. Update workflows to use `runs-on: self-hosted`

## Workflow Files Updated

The following changes were made to improve compatibility:

| File | Change |
|------|--------|
| `build-project.yaml` | `ubuntu-24.04` → `ubuntu-latest` |
| `build-project.yaml` | `macos-15` → `macos-latest` |
| `build-project.yaml` | `Xcode_26.1` → `Xcode_15.2` |
| All workflows | `windows-2022` → `windows-latest` |
| `tests.yaml` | Added proper permissions |
| `ci-minimal.yaml` | New minimal workflow with status reporting |

## Verifying CI/CD

After enabling Actions:

1. Push a commit to master
2. Check the Actions tab
3. Verify all jobs complete successfully

## Contact

For billing questions, contact GitHub Support.
