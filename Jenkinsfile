pipeline {
    agent {
        docker {
            image 'project-tsurugi/frontend'
            label 'docker'
        }
    }
    environment {
        GITHUB_URL = 'https://github.com/project-tsurugi/frontend'
        GITHUB_CHECKS = 'tsurugi-check'
        BUILD_PARALLEL_NUM="""${sh(
                returnStdout: true,
                script: 'grep processor /proc/cpuinfo | wc -l'
            )}"""
    }
    stages {
        stage ('Prepare env') {
            steps {
                sh '''
                    ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
                '''
            }
        }
        stage ('build PostgreSQL') {
            steps {
                sh '''
                    tar -xf /postgresql-11.1.tar.bz2
                    cd postgresql-11.1
                    ./configure --prefix=$HOME/pgsql
                    make -j${BUILD_PARALLEL_NUM}
                    make install
                '''
            }
        }
        stage ('checkout master') {
            steps {
                dir ('postgresql-11.1/contrib/frontend') {
                    checkout scm
                    sh '''
                        git clean -dfx
                        git submodule sync --recursive
                        git submodule update --init --recursive
                    '''
                }
            }
        }
        stage ('build ogawayama') {
            steps {
                sh '''
                   cd postgresql-11.1/contrib/frontend/third_party/ogawayama
                   git clean -dfx
                   mkdir build
                   cd build
                   cmake -DBUILD_STUB_ONLY=ON -DBUILD_TESTS=OFF ..
                   make -j${BUILD_PARALLEL_NUM}
                '''
            }
        }
        stage ('build metadata-manager') {
            steps {
                sh '''
                    cd postgresql-11.1/contrib/frontend/third_party/manager/metadata-manager
                    git clean -dfx
                    mkdir build
                    cd build
                    cmake ..
                    make -j${BUILD_PARALLEL_NUM}
                '''
            }
        }
        stage ('build frontend') {
            steps {
                sh '''
                    cd postgresql-11.1/contrib/frontend
                    make -j${BUILD_PARALLEL_NUM}
                    make install
                '''
            }
        }
    }
}
