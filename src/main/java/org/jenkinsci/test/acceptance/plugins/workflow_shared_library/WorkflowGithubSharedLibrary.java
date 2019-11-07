package org.jenkinsci.test.acceptance.plugins.workflow_shared_library;

import org.jenkinsci.test.acceptance.plugins.workflow_multibranch.GithubBranchSource;
import org.jenkinsci.test.acceptance.po.Control;
import org.jenkinsci.test.acceptance.po.PageAreaImpl;

/**
 * Base type for {@link PageAreaImpl} for Pipeline Shared Library using Github as SCM.
 */
public class WorkflowGithubSharedLibrary extends WorkflowSharedLibrary {

    public final Control modernScm = control("retriever[0]");
    public final Control githubSourceCodeManagement = control("retriever[0]/scm[1]");
    public final Control repositoryUrl = control("repositoryUrl");

    public WorkflowGithubSharedLibrary(WorkflowSharedLibraryGlobalConfig config, String path) {
        super(config, path);
    }

    @Override
    public GithubBranchSource selectSCM() {
        this.modernScm.click();
        this.githubSourceCodeManagement.waitFor();
        this.githubSourceCodeManagement.click();

        return new GithubBranchSource(this, this.getPath() + "/retriever[0]/scm[1]");
    }
    // Allows for use of the new GitHub Branch Source single repository selector
    public GithubBranchSource selectSCMWithNewUI(String repositoryHTTPSUrl) {
        this.modernScm.click();
        this.githubSourceCodeManagement.waitFor();
        this.githubSourceCodeManagement.click();
        this.repositoryUrl.set(repositoryHTTPSUrl);

        return new GithubBranchSource(this, this.getPath() + repositoryUrl);

    }
}
