package com.shms.worker;

import java.util.List;

import org.springframework.stereotype.Repository;

@Repository
public interface WorkerMapper {
	public int count(Worker worker) throws Exception;
	public List<Worker> list(Worker worker) throws Exception;
	public Worker select(Worker worker) throws Exception;
	public void insert(Worker worker) throws Exception;
	public void update(Worker worker) throws Exception;
	public void delete(Worker worker) throws Exception;
}
