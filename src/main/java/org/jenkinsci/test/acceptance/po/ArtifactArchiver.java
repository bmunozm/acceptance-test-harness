package org.jenkinsci.test.acceptance.po;

/**
 * @author Kohsuke Kawaguchi
 */
@BuildStepPageObject("Archive the artifacts")
public class ArtifactArchiver extends PostBuildStep {
    public ArtifactArchiver(Job parent, String path) {
        super(parent, path);
    }

    public ArtifactArchiver includes(String value) {
        control("artifacts").sendKeys(value);
        return this;
    }

    public ArtifactArchiver excludes(String value) {
        control("advanced-button").click();
        control("excludes").sendKeys(value);
        return this;
    }

    public ArtifactArchiver latestOnly(boolean check) {
        control("advanced-button").click();
        check(control("latestOnly"),check);
        return this;
    }
}